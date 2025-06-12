<?php
require_once 'assets\db.php';
require_once 'sidebar.php';
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'update_order') {
    $stmt = $pdo->prepare("
        UPDATE CHI_TIET_DON_HANG c
        JOIN DON_HANG d ON c.MA_DON_HANG = d.MA_DON_HANG
        SET 
            c.MA_DON_HANG            = ?,
            c.MA_SAN_PHAM            = ?,
            c.SO_LUONG               = ?,
            c.DON_GIA                = ?,      
            d.TRANG_THAI_DON_HANG    = ?
        WHERE c.MA_CHI_TIET_DON_HANG = ?
    ");
    $stmt->execute([
        $_POST['ma_don_hang'], 
        $_POST['ma_san_pham'], 
        $_POST['so_luong'], 
        $_POST['price'],         
        $_POST['trang_thai_don_hang'],
        $_POST['id']
    ]);
    header("Location: order_details.php");
    exit;
}


// Handle deletion
if (isset($_GET['delete'])) {
    $stmt = $pdo->prepare("DELETE FROM CHI_TIET_DON_HANG WHERE MA_CHI_TIET_DON_HANG = ?");
    $stmt->execute([$_GET['delete']]);
    header("Location: order_details.php");
    exit;
}

// Fetch all records
$stmt = $pdo->query("
    SELECT 
        c.MA_CHI_TIET_DON_HANG,
        c.MA_DON_HANG,
        c.MA_SAN_PHAM,
        s.TEN_SAN_PHAM,
        c.SO_LUONG,
        c.DON_GIA,
        d.TRANG_THAI_DON_HANG
    FROM CHI_TIET_DON_HANG c
    JOIN SAN_PHAM s ON c.MA_SAN_PHAM = s.MA_SAN_PHAM
    JOIN DON_HANG d ON c.MA_DON_HANG = d.MA_DON_HANG
");
$orderDetails = $stmt->fetchAll();

// Fetch all orders with user info
$ordersStmt = $pdo->query("
  SELECT dh.MA_DON_HANG, dh.MA_NGUOI_DUNG, dh.TONG_TIEN, dh.DIA_CHI_GIAO_HANG,
         dh.PHUONG_THUC_THANH_TOAN, dh.TRANG_THAI_DON_HANG, dh.NGAY_TAO,
         nd.HO_TEN, nd.EMAIL
  FROM DON_HANG dh
  JOIN NGUOI_DUNG nd ON dh.MA_NGUOI_DUNG = nd.MA_NGUOI_DUNG
");
$ordersRaw = $ordersStmt->fetchAll(PDO::FETCH_ASSOC);

// Fetch all details
$detailsStmt = $pdo->query("
  SELECT c.MA_DON_HANG, c.MA_SAN_PHAM, s.TEN_SAN_PHAM, c.SO_LUONG, c.DON_GIA
  FROM CHI_TIET_DON_HANG c
  JOIN SAN_PHAM s ON c.MA_SAN_PHAM = s.MA_SAN_PHAM
");
$detailsRaw = $detailsStmt->fetchAll(PDO::FETCH_ASSOC);

// Group details by order
$orderDetails = [];
foreach ($ordersRaw as $order) {
    $order['products'] = [];
    $orderDetails[$order['MA_DON_HANG']] = $order;
}
foreach ($detailsRaw as $d) {
    $orderDetails[$d['MA_DON_HANG']]['products'][] = $d;
}

?>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders</title>
    <link rel="stylesheet" href="assets\style.css">
</head>

<body>
    <div class="layout">
        <?php loadSidebar(); ?>

        <div class="main-content">
            <div class="header">
                <h1>Quản lý đơn hàng</h1>
            </div>
            <?php foreach ($orderDetails as $order): ?>
            <!-- Order Card -->
            <div class="order-card"
                style="border:1px solid var(--card);padding:1rem;border-radius:8px;margin:1rem 0; background:var(--card);">
                <h3>Đơn #<?= $order['MA_DON_HANG'] ?> &mdash; <?= htmlspecialchars($order['HO_TEN']) ?></h3>
                <p><strong>Tổng tiền:</strong> <?= number_format($order['TONG_TIEN'], 0, ',', '.') ?> VND</p>
                <p><strong>Địa chỉ:</strong> <?= htmlspecialchars($order['DIA_CHI_GIAO_HANG']) ?></p>
                <p><strong>Trạng thái:</strong> <?= htmlspecialchars($order['TRANG_THAI_DON_HANG']) ?></p>
                <p><strong>Ngày tạo:</strong> <?= htmlspecialchars($order['NGAY_TAO']) ?></p>
                <p><strong>Sản phẩm:</strong></p>
                <ul>
                    <?php foreach ($order['products'] as $p): ?>
                    <li>
                        <?= htmlspecialchars($p['TEN_SAN_PHAM']) ?> —
                        SL: <?= $p['SO_LUONG'] ?> —
                        Giá: <?= number_format($p['DON_GIA'], 0, ',', '.') ?> VND
                    </li>
                    <?php endforeach; ?>
                </ul>

                <div style="margin-top:1rem;">
                    <button class="btn btn-primary" onclick="openEditModal(<?= $order['MA_DON_HANG'] ?>)">Edit</button>

                    <button class="btn btn-primary" style="background-color: red;" type="button"
                        onclick="if (confirm('Bạn có chắc muốn xóa đơn hàng #<?= $order['MA_DON_HANG'] ?>?')) window.location='?delete_order=<?= $order['MA_DON_HANG'] ?>';">Delete
                        Order</button>

                </div>
            </div>

            <!-- Edit Modal -->
            <div id="modal-<?= $order['MA_DON_HANG'] ?>" class="modal-overlay"
                style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);justify-content:center;align-items:center;z-index:1000;">
                <div class="modal-card"
                    style="background:var(--card);padding:1.5rem;border-radius:8px;max-width:600px;width:90%;position:relative;">
                    <button class="modal-close" onclick="closeEditModal(<?= $order['MA_DON_HANG'] ?>)"
                        style="position:absolute;top:.5rem;right:.5rem;background:none;border:none;font-size:1.5rem;color:var(--text);cursor:pointer;">×</button>

                    <h2>Chỉnh sửa Đơn #<?= $order['MA_DON_HANG'] ?></h2>
                    <form method="post" action="order_details.php">
                        <input type="hidden" name="action" value="update_order">
                        <input type="hidden" name="id" value="<?= $order['MA_DON_HANG'] ?>">

                        <table class="table" style="width:100%;border-collapse:collapse;">
                            <tr>
                                <th>Mã đơn hàng</th>
                                <td><input name="ma_don_hang" value="<?= $order['MA_DON_HANG'] ?>"></td>
                            </tr>
                            <tr>
                                <th>Trạng thái</th>
                                <td>
                                    <select name="trang_thai_don_hang">
                                        <?php foreach (['CHO_XU_LY','DANG_XU_LY','DA_GIAO','HOAN_THANH','DA_HUY'] as $st): ?>
                                        <option value="<?= $st ?>"
                                            <?= $order['TRANG_THAI_DON_HANG'] == $st ? 'selected' : '' ?>>
                                            <?= $st ?>
                                        </option>
                                        <?php endforeach; ?>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th>Tổng tiền</th>
                                <td><input name="tong_tien" value="<?= $order['TONG_TIEN'] ?>"></td>
                            </tr>
                            <tr>
                                <th>Địa chỉ giao</th>
                                <td><input name="dia_chi" value="<?= htmlspecialchars($order['DIA_CHI_GIAO_HANG']) ?>">
                                </td>
                            </tr>
                            <tr>
                                <th>Phương thức</th>
                                <td><input name="pttt"
                                        value="<?= htmlspecialchars($order['PHUONG_THUC_THANH_TOAN']) ?>"></td>
                            </tr>
                            <tr>
                                <th>Sản phẩm</th>
                                <td>
                                    <ul style="padding-left:1.2rem;">
                                        <?php foreach ($order['products'] as $p): ?>
                                        <li>
                                            <input type="number" name="prod_<?= $p['MA_SAN_PHAM'] ?>_qty"
                                                value="<?= $p['SO_LUONG'] ?>" style="width:60px;">
                                            <?= htmlspecialchars($p['TEN_SAN_PHAM']) ?>
                                        </li>
                                        <?php endforeach; ?>
                                    </ul>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" style="text-align:right;padding-top:1rem;">
                                    <button class="btn btn-primary" type="submit">Lưu</button>
                                    <button type="button" class="btn btn-secondary"
                                        onclick="closeEditModal(<?= $order['MA_DON_HANG'] ?>)">Hủy</button>
                                </td>
                            </tr>
                        </table>
                    </form>
                </div>
            </div>
            <?php endforeach; ?>

            <!-- JavaScript -->
            <script>
            function openEditModal(orderId) {
                document.getElementById('modal-' + orderId).style.display = 'flex';
            }

            function closeEditModal(orderId) {
                document.getElementById('modal-' + orderId).style.display = 'none';
            }
            </script>


        </div>
    </div>


</body>

</html>

<script>
function openEditModal(orderId) {
    document.getElementById('modal-' + orderId).style.display = 'flex';
}

function closeEditModal(orderId) {
    document.getElementById('modal-' + orderId).style.display = 'none';
}
</script>