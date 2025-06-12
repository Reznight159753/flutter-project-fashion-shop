Hướng dẫn setup để chạy được code 
Bước 1: Cấu hình SDK Flutter
•	Mở Nhom2\doan_commerce_app\android\local.properties, chỉnh sửa SDK.
 
Bước 2: Cập nhật NDK
•	Mở Nhom2\doan_commerce_app\android\app\build.gradle.kts, sửa ndkVersion trong phần android.
 

Bước 3: Tìm kiếm XAMPP
•	Mở Google Chrome, tìm "xampp download". Hoặc truy cập đường link này https://www.apachefriends.org/download.html
 
Bước 4: Tải XAMPP
•	Chọn liên kết tải phù hợp, nhấn "Download".
 
Bước 5: Cài đặt XAMPP
•	Cài XAMPP và đặt file đúng vào ổ C: (C:\xampp).
 
Bước 6: Sao chép API
•	Copy thư mục shop_api từ Project Nhom2 vào C:\xampp\htdocs.
 
Bước 7: Mở XAMPP Control
•	Vào C:\xampp, chạy file xampp-control.exe.
 
Bước 8: Khởi động dịch vụ
•	Nhấn "Start" cho Apache và MySQL. Đảm bảo cổng MySQL là 3306 (mặc định). Không tắt XAMPP Control Panel.
 
Bước 9: Truy cập phpMyAdmin
•	Nhấn "Admin" cạnh MySQL để vào phpMyAdmin.
 
Bước 10: Tạo cơ sở dữ liệu
•	Trong phpMyAdmin, chọn mới,tạo cơ sở dữ liệu tên shop_nhom9.
 
Bước 11: Nhập file SQL
•	Chọn vào data vừa tạo -> chọn tab Nhập -> Chọn Tệp -> Nhập
 


Bước 12: Kết quả:
 
Bước 13: Vào code nhập (flutter pub get)
----------------------------------------------------Admin page-------------------------------------------------------
Bước 1: Copy file “adminpageFlutter” 
Bước 2: Paste vào C:\xampp\htdocs
Bước 3: Truy cập gg
Bước 4: Điền link: http://localhost/adminpageFlutter/
Bước 5: Nhấn enter.
Lưu ý: xampp-controll phải đang Starts Apache và MySQL để kết nối được database
