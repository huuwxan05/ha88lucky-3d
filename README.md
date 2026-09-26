# Royal Online V2

Bản V2 dùng PHP 8.3 + PostgreSQL + Apache, phù hợp deploy Render. Có đăng ký/đăng nhập, ví TEST, game demo, quản lý người chơi, nạp/rút TEST, chatbot FAQ, chat hỗ trợ admin và audit log.

## Deploy Render
1. Upload toàn bộ thư mục lên GitHub.
2. Render → New → Blueprint → chọn repo có `render.yaml`.
3. Render tạo web service và PostgreSQL. `DATABASE_URL` được nối tự động.
4. Mở `/` cho người chơi và `/admin.html` cho admin.

## Tạo admin đầu tiên
Sau khi DB chạy, tạo hash bằng PHP `password_hash` rồi INSERT một user với `role=admin`; không commit mật khẩu thật vào GitHub. Ví dụ SQL: `INSERT INTO users(username,email,password_hash,role) VALUES ('admin','admin@example.com','<HASH>','admin');` và tạo wallet tương ứng.

## V2
- Yêu cầu nạp/rút được lưu PostgreSQL và admin duyệt/từ chối.
- Duyệt nạp/rút tạo wallet transaction + audit log.
- Chat thread giữa người chơi và admin.
- FAQ chatbot dạng rule/FAQ, không cần API AI bên ngoài.
- Số dư chỉ là TEST balance; không phải tiền thật.

## V3 - HA88Lucky
- Player character name during registration.
- Community lobby chat with clearly labeled automated bot replies.
- HA88Lucky branding and responsive 3D-style UI effects.
- Per-game audio configuration API (`game_audio_settings`) and admin endpoint.
- Existing admin controls remain available for users, wallet, deposits/withdrawals, games, and audit logs.
- The UI uses lightweight Web Audio effects by default; production can replace them with licensed per-game music/effect URLs through the admin audio settings.
- 3D visual effects in this package are UI/animation effects, not a full 3D game engine. A real 3D scene requires game assets/engine integration.


## V4 - HA88Lucky 3D
- Added a browser-based Three.js 3D game/lobby prototype at `public/game3d/`.
- Game cards launch the 3D scene with a game-specific `?game=` parameter.
- Responsive WebGL renderer, lighting, shadows, fog, camera controls and animated objects are included.
- `assets/3d/` is reserved for owned/licensed GLB/GLTF assets.
- This is a safe 3D prototype, not a full commercial game engine build.
