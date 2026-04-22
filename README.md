# 🚀 5-Stage Pipelined RISC-V Processor

![Language](https://img.shields.io/badge/Language-Verilog%20%2F%20SystemVerilog-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V-orange.svg)
![Simulation](https://img.shields.io/badge/Simulation-GTKWave-brightgreen.svg)

## 📖 Giới thiệu (Overview)

Dự án này triển khai mã nguồn RTL (Register-Transfer Level) cho một bộ vi xử lý trung tâm (CPU) dựa trên kiến trúc **Pipeline 5 tầng**. Thiết kế bao gồm đầy đủ các khối chức năng cơ bản của một Datapath chuẩn và đi kèm với môi trường kiểm thử (testbench) chặt chẽ để xác minh hoạt động của vi mạch thông qua mô phỏng dạng sóng.

### ✨ Các tính năng chính:
- **Kiến trúc Pipeline 5 tầng**: Tối ưu hóa thông lượng lệnh qua các giai đoạn: Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), và Write-Back (WB).
- **Thiết kế Datapath hoàn chỉnh**: Bao gồm các thanh ghi chốt (Pipeline Registers), khối giải quyết xung đột (Hazard Unit / Forwarding), ALU, và bộ nhớ.
- **Môi trường Testbench (Simulation)**: Theo dõi trực quan các tín hiệu nội bộ, thanh ghi, và trạng thái bộ nhớ qua từng chu kỳ xung nhịp.

---

## 🏛️ Sơ đồ Kiến trúc (Architecture Datapath)

Bộ vi xử lý được thiết kế theo sơ đồ Datapath dưới đây. Các thanh ghi Pipeline (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) được tích hợp để cô lập dữ liệu giữa các tầng, giúp CPU có thể xử lý gối đầu nhiều lệnh cùng lúc.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9537fa8a-7f3e-44d8-93d2-22e6479714c0" alt="5-Stage Pipeline Datapath" width="90%">
</p>

---

## 📊 Phân tích Dạng sóng (Waveform Simulation)

Quá trình kiểm tra (Verification) được thực hiện chặt chẽ. Dưới đây là kết quả mô phỏng trên **GTKWave**, cho phép quan sát chi tiết sự thay đổi của các tín hiệu quan trọng như `clk`, `pc`, `instruction`, và dữ liệu các thanh ghi qua từng chu kỳ hoạt động.

<p align="center">
  <img src="https://github.com/user-attachments/assets/1c1b0052-49da-446a-baa3-e7339beb6844" alt="GTKWave Simulation Result" width="100%">
</p>

---

## 🛠️ Công cụ phát triển (Tools & Environment)

* **Hardware Description Language**: Verilog / SystemVerilog
* **Trình biên dịch & Mô phỏng**: Icarus Verilog / ModelSim
* **Trình xem dạng sóng (Waveform Viewer)**: GTKWave

---

