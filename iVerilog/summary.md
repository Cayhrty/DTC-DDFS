# DDS 芯片顶层模块使用说明

本仓库包括一个 DDS（直接数字合成器）芯片的顶层 Verilog 代码，测试平台
`chip_top_tb.v` 及配套模块。`chip_top` 模块集成了：

- SPI 从机控制（`spi_slv_top`）用于寄存器访问
- 基准和高速时钟的复位同步
- 帧/空闲控制的使能状态机
- 核心计算模块 `dtcdds`
- 输出选择逻辑（`output_select`）
- 测试模式 RAM，用于注入预计算边缘数据

## 寄存器表

通过 SPI 访问寄存器，格式为 1 位写/读标志、5 位长度、10 位地址，随后
`length*8` 位数据。地址空间至少覆盖 0–79。所有字段在 `chip_top` 内被打包到一个
宽 `slv_reg_out` 总线（79 字节 = 632 位）。

| 地址 | 描述                                    | 宽度  | 备注 |
|------|------------------------------------------|-------|-------|
| 0    | `dphi_slope`                             | 8     | DDS 斜率参数 |
| 1    | `iacc_slope`                             | 16    | 积分斜率 |
| 3    | `inv_delta_phi_Preset`                   | 16    | |
| 5    | `phiApreset`                             | 18    | 24 位字段仅低位有效 |
| 8    | `phiBpreset`                             | 18    | |
| 11   | `phiCpreset`                             | 18    | |
| 14   | `phiDpreset`                             | 18    | |
| 17   | `dPhiPresetA`                            | 18    | |
| 20   | `dPhiPresetB`                            | 18    | |
| 23   | `dPhiPresetC`                            | 18    | |
| 26   | `dPhiPresetD`                            | 18    | |
| 29   | `CONTROL_REG`                            | 8     | [ram_cs(1), output_select_mode(1), test_mode_enable(1), rst_n(1), command(4)] |
| 30   | `TEST_MODE_RAM_REG`                      | 8     | [wr_en(1), wr_addr(4), 保留(3)] |
| 31   | `frame_len`                              | 16    | 状态机帧长 |
| 33   | `idle_len`                               | 16    | 状态机空闲长度 |
| 35-79 | `RAM DATA IN`                          | 每个 8 | 当设置测试模式时，写入 RAM 数据 |

> **注意：** 地址 79 以上的寄存器目前逻辑中未使用。

### 控制寄存器位分配
```
CONTROL_REG (地址 29):
  [7] ram_cs //low active
  [6] output_select_mode // 0 : fifo mode , 1 : test mode
  [5] test_mode_enable // 0 : fifo mode , 1 : test mode
  [4] rst_n
  [3:0] command  // 0=NOP,1=RUN,2=AUTO 等
```

```
TEST_MODE_RAM_REG (地址 30):
  [7] wr_en
  [6:3] wr_addr
  [2:0] 保留
```

## 编程顺序

1. **SPI 初始化**：拉高 `spi_csn_pad` 并将 `spi_rstn_pad` 先置 0 后置 1 复位。
2. **写配置寄存器**
   - 发送写命令，地址设为 0，长度覆盖需要更新的所有寄存器。
   - **SPI 协议一次连续读写最多 32 字节，因此如需配置超出 32 字节的数据范围，需要分多次事务进行。**
   - 多字节写操作先传输 16 位命令字，然后是数据字节。
   - 测试平台示例中在一次事务中写入地址 0–31 (`cmd_test[0]`)。
3. **设置帧/空闲长度**：在地址 31 写 `frame_len`，在 33 写 `idle_len`。
4. **可选加载 RAM**：
   - 在 CONTROL_REG 中将 `test_mode_enable` 置 1。
   - 写 `TEST_MODE_RAM_REG`，`wr_en` 置 1 并选择写入地址，然后从 35 起发送 8 位数据。
   - 切换 `ram_cs` 以锁存数据。
5. **解除复位**：在 CONTROL_REG 中将 `rst_n` 置 1 并设置 `command` 为所需状态。
6. **启动操作**：
   - CONTROL_REG 的 `command` 字段：1=RUN（单帧），2=AUTO（连续帧），0=STOP。
     `enable_state_machine` 处理帧计数和流水线时序。
7. **监控输出**：
   - 边缘数据从 8 位总线 `edgeA_out` … `edgeH_out` 输出。
   - 选择信号（`selAA`等）指示当前通道。
   - DAC 选择信号 (`DAC_selA` … `DAC_selH`) 用于外部 DAC。

## 状态机操作说明

`enable_state_machine.v` 实现了四个主要状态：

1. **IDLE (0)**
   - `enable`=0，帧计数清零，等待 `command` 为 RUN 或 AUTO。
   - 如果收到 RUN，进入 RUN 状态；若为 AUTO，则进入 AUTO 状态。
   - `reset_calc_module` 通过低电平保持计算模块复位。
2. **RUN (1)**
   - `frame_counter` 增加直到达到 `frame_len`，然后回到 IDLE 并复位计算模块。
   - `pipeline_counter` 达到 3 时将 `enable` 置 1，以输出有效数据。
3. **AUTO continue (2)**
   - 类似 RUN，但在 `frame_len` 达到后进入 AUTO idle 状态，除非收到 STOP 命令。
   - 在此状态下 `reset_calc_module` 维持有效，`enable` 随管线计数变化。
4. **AUTO idle (3)**
   - 在空闲计数达 `idle_len` 后返回 AUTO continue 状态，`reset_calc_module` 复位。

状态机以 `command` 变化驱动，可通过 SPI 更新 CONTROL_REG:
- 0 = 停止/空闲
- 1 = 运行单帧
- 2 = 自动连续

复位（`rst_n` 字段）和流水线逻辑保证在状态转移期间计算模块被正确复位。

## 测试平台使用

`chip_top_tb.v` 展示了 500 MHz 与 2 GHz 时钟产生、SPI 事务和文件日志。使用 Icarus Verilog
(`iverilog`/`vvp`) 生成 `wave.vcd` 和文本输出文件 (`final_p2s_data_out.txt`)。
测试平台进行三次 SPI 写操作：批量配置、帧/空闲长度写入、以及最终的控制寄存器写入以
release reset 并启动处理。

文件日志在每个 `clk_hs` 上升沿记录边缘输出和选择信号。

## 驱动程序编写

首先，扫频起始点固定为0.5*Fref

确定归一化扫频斜率dphi_slope 8bit 
fref为12.8GHz时每个LSB的权重是30.51758MHz/us

根据dphi_slope输入计算iacc_slope其具体值为左移四位
inv_delta_phi_preset = 16'b1111_1111_1111_0010

根据dphi_slope计算相位初值并截断至18bit
phi_fmcw_euler_fix(ii) = phi_fmcw_euler_fix(ii-1) + (delta_phi_fmcw_euler_fix(ii)+delta_phi_fmcw_euler_fix(ii-1))/2;

根据dphi_slope计算相位导数初值，具体为A=0，B=dphi_slope/4,C=dphi_slope/2,D=dphi_slope*3/4

根据扫频结束点计算frame长度和空闲长度写入寄存器frame_len和idle_len，其中长度为数字低速CLK的周期数
配置控制状态机，释放复位开始扫描


此文档帮助用户通过 SPI 配置和驱动 DDS 芯片，并理解内部寄存器字段和状态机行为。