# 🚀 5-Stage Pipelined Processor Implementation

![Verilog](https://img.shields.io/badge/Language-Verilog/SystemVerilog-blue.svg)
![Simulation](https://img.shields.io/badge/Simulation-GTKWave-green.svg)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V%20Pipeline-orange.svg)
![Status](https://img.shields.io/badge/Status-Simulation%20Passing-brightgreen.svg)

## 📖 Giới thiệu (About)

Dự án này triển khai mã nguồn RTL (Register-Transfer Level) cho một bộ vi xử lý dựa trên kiến trúc **Pipeline 5 tầng**. Thiết kế bao gồm đầy đủ các khối chức năng cơ bản của một Datapath chuẩn và đi kèm với môi trường kiểm thử (testbench) để xác minh hoạt động của CPU thông qua mô phỏng dạng sóng.

### ✨ Các tính năng chính:
- **Kiến trúc Pipeline 5 tầng**: Bao gồm các giai đoạn Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), và Write-Back (WB).
- **Hỗ trợ các lệnh cơ bản**: Các tập lệnh xử lý toán học (ALU), truy xuất bộ nhớ (Load/Store), và rẽ nhánh (Branch).
- **Môi trường Testbench hoàn chỉnh**: Dễ dàng chạy mô phỏng và theo dõi các tín hiệu nội bộ như `clk`, `pc`, `instruction`, `rs1_data`, `rs2_data`, v.v.

---

## 🏛️ Sơ đồ Kiến trúc (Architecture Datapath)

Bộ vi xử lý được thiết kế theo sơ đồ Datapath dưới đây, với các thanh ghi Pipeline (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) giúp tăng thông lượng xử lý lệnh.

![Pipeline Datapath](./images/datapath.png) 
*(Lưu ý: Thay thế đường dẫn `./images/datapath.png` bằng hình ảnh sơ đồ của bạn)*

---

## 📊 Phân tích Dạng sóng (Waveform Simulation)

Dự án sử dụng file `.vcd` được xuất ra từ quá trình mô phỏng để phân tích hoạt động trên **GTKWave**. Các tín hiệu quan trọng được theo dõi sát sao để đảm bảo tính chính xác của từng chu kỳ xung nhịp (clock cycle).

![GTKWave Simulation](./images/waveform.png)
*(Lưu ý: Thay thế đường dẫn bằng hình ảnh chụp màn hình GTKWave của bạn)*

---

## 🛠️ Công cụ yêu cầu (Prerequisites)

Để biên dịch và chạy mô phỏng dự án này, bạn cần cài đặt các công cụ sau:
* **Trình biên dịch HDL**: [Icarus Verilog](http://iverilog.icarus.com/) hoặc ModelSim / Vivado.
* **Trình xem dạng sóng**: [GTKWave](http://gtkwave.sourceforge.net/).

---

## 🚀 Hướng dẫn chạy mô phỏng (Getting Started)

Dưới đây là các bước cơ bản để chạy mô phỏng sử dụng Icarus Verilog và GTKWave trên Terminal:

**Bước 1: Clone dự án về máy**
```bash
git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
cd your-repo-name
