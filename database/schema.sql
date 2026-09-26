CREATE TABLE IF NOT EXISTS users(id BIGSERIAL PRIMARY KEY,username VARCHAR(32) UNIQUE NOT NULL,email VARCHAR(190) UNIQUE NOT NULL,password_hash VARCHAR(255) NOT NULL,role VARCHAR(16) NOT NULL DEFAULT 'user' CHECK(role IN('user','admin')),status VARCHAR(16) NOT NULL DEFAULT 'active' CHECK(status IN('active','blocked')),created_at TIMESTAMPTZ NOT NULL DEFAULT now(),updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),last_login_at TIMESTAMPTZ);
CREATE TABLE IF NOT EXISTS wallets(user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,balance BIGINT NOT NULL DEFAULT 1000000 CHECK(balance>=0),updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS wallet_transactions(id BIGSERIAL PRIMARY KEY,user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,type VARCHAR(20) NOT NULL,amount BIGINT NOT NULL,balance_before BIGINT NOT NULL,balance_after BIGINT NOT NULL,reference_type VARCHAR(40),reference_id BIGINT,description VARCHAR(255),created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS idx_wallet_tx_user ON wallet_transactions(user_id,created_at DESC);
CREATE TABLE IF NOT EXISTS games(id SERIAL PRIMARY KEY,code VARCHAR(32) UNIQUE NOT NULL,name VARCHAR(80) NOT NULL,category VARCHAR(40) NOT NULL,status VARCHAR(16) NOT NULL DEFAULT 'active' CHECK(status IN('active','maintenance','disabled')),min_bet BIGINT NOT NULL DEFAULT 1000 CHECK(min_bet>0),max_bet BIGINT NOT NULL DEFAULT 10000000 CHECK(max_bet>=min_bet),round_seconds INT NOT NULL DEFAULT 30 CHECK(round_seconds BETWEEN 5 AND 3600),sort_order INT NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS game_rounds(id BIGSERIAL PRIMARY KEY,game_id INT NOT NULL REFERENCES games(id),round_no VARCHAR(64) UNIQUE NOT NULL,status VARCHAR(16) NOT NULL DEFAULT 'open',result_json JSONB,created_at TIMESTAMPTZ NOT NULL DEFAULT now(),settled_at TIMESTAMPTZ);
CREATE TABLE IF NOT EXISTS bets(id BIGSERIAL PRIMARY KEY,user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,game_id INT NOT NULL REFERENCES games(id),round_id BIGINT REFERENCES game_rounds(id) ON DELETE SET NULL,selection VARCHAR(80) NOT NULL,stake BIGINT NOT NULL CHECK(stake>0),payout BIGINT NOT NULL DEFAULT 0,status VARCHAR(16) NOT NULL DEFAULT 'accepted',created_at TIMESTAMPTZ NOT NULL DEFAULT now(),settled_at TIMESTAMPTZ);
CREATE INDEX IF NOT EXISTS idx_bets_user ON bets(user_id,created_at DESC);
CREATE TABLE IF NOT EXISTS audit_logs(id BIGSERIAL PRIMARY KEY,actor_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,action VARCHAR(100) NOT NULL,target_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,ip_address VARCHAR(45),user_agent VARCHAR(500),payload_json JSONB,created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs(created_at DESC);
CREATE TABLE IF NOT EXISTS app_settings(setting_key VARCHAR(80) PRIMARY KEY,setting_value TEXT,updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
INSERT INTO games(code,name,category,status,min_bet,max_bet,round_seconds,sort_order) VALUES ('taixiu','Tài Xỉu','dice','active',1000,10000000,30,1),('sicbo','Sicbo','dice','active',1000,10000000,30,2),('dragon','Rồng Hổ','cards','active',1000,10000000,30,3),('baucua','Bầu Cua','dice','active',1000,10000000,30,4),('blackjack','Xì Dách','cards','active',1000,10000000,30,5),('xocdia','Xóc Đĩa','coins','active',1000,10000000,30,6),('baccarat','Baccarat','cards','active',1000,10000000,30,7),('slot','Slot','casino','active',1000,10000000,30,8),('sports','Thể Thao','sports','active',1000,10000000,30,9),('lottery','Lô Đề','lottery','active',1000,10000000,30,10) ON CONFLICT(code) DO NOTHING;
INSERT INTO app_settings(setting_key,setting_value) VALUES('virtual_balance_mode','1'),('registration_bonus','1000000') ON CONFLICT(setting_key) DO NOTHING;


CREATE TABLE IF NOT EXISTS money_requests(id BIGSERIAL PRIMARY KEY,user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,type VARCHAR(12) NOT NULL CHECK(type IN('deposit','withdraw')),amount BIGINT NOT NULL CHECK(amount>0),method VARCHAR(80),account_info VARCHAR(255),proof_note VARCHAR(500),status VARCHAR(16) NOT NULL DEFAULT 'pending' CHECK(status IN('pending','approved','rejected')),admin_note VARCHAR(500),created_at TIMESTAMPTZ NOT NULL DEFAULT now(),processed_at TIMESTAMPTZ,processed_by BIGINT REFERENCES users(id) ON DELETE SET NULL);
CREATE INDEX IF NOT EXISTS idx_money_requests_status ON money_requests(status,created_at DESC);
CREATE TABLE IF NOT EXISTS chat_threads(id BIGSERIAL PRIMARY KEY,user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,status VARCHAR(16) NOT NULL DEFAULT 'open' CHECK(status IN('open','closed')),created_at TIMESTAMPTZ NOT NULL DEFAULT now(),updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS chat_messages(id BIGSERIAL PRIMARY KEY,thread_id BIGINT NOT NULL REFERENCES chat_threads(id) ON DELETE CASCADE,sender_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,sender_type VARCHAR(16) NOT NULL CHECK(sender_type IN('user','admin','bot')),message TEXT NOT NULL,created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS idx_chat_messages_thread ON chat_messages(thread_id,created_at);
CREATE TABLE IF NOT EXISTS support_faq(id SERIAL PRIMARY KEY,question VARCHAR(255) NOT NULL,answer TEXT NOT NULL,active BOOLEAN NOT NULL DEFAULT TRUE);
INSERT INTO support_faq(question,answer) VALUES
('Nạp tiền hoạt động thế nào?','Tạo yêu cầu Nạp tiền, nhập số TEST và phương thức. Admin sẽ xem xét và cập nhật trạng thái.'),
('Rút tiền hoạt động thế nào?','Tạo yêu cầu Rút tiền, nhập số TEST và thông tin nhận. Với bản TEST, admin duyệt thủ công và mọi thay đổi được ghi nhật ký.'),
('Bao lâu được hỗ trợ?','Bạn có thể gửi tin nhắn trong mục Hỗ trợ; admin sẽ trả lời trong cuộc trò chuyện.'),
('Tôi quên mật khẩu thì sao?','Bản V2 chưa có email reset tự động. Hãy liên hệ admin để được hướng dẫn.'),
('Số dư TEST là gì?','Đây là số dư thử nghiệm của hệ thống, không phải tiền thật.')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS player_profiles (
 id BIGSERIAL PRIMARY KEY,
 user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 character_name VARCHAR(32) UNIQUE NOT NULL,
 avatar VARCHAR(32) NOT NULL DEFAULT 'warrior',
 level INT NOT NULL DEFAULT 1,
 exp BIGINT NOT NULL DEFAULT 0,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS lobby_messages (
 id BIGSERIAL PRIMARY KEY,
 user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
 sender_name VARCHAR(64) NOT NULL,
 message TEXT NOT NULL,
 is_bot BOOLEAN NOT NULL DEFAULT FALSE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS game_audio_settings (
 game_code VARCHAR(40) PRIMARY KEY,
 music_url TEXT NOT NULL DEFAULT '',
 effect_url TEXT NOT NULL DEFAULT '',
 volume NUMERIC(4,3) NOT NULL DEFAULT 0.7,
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO game_audio_settings(game_code) VALUES
('taixiu'),('sicbo'),('dragon'),('baucua'),('blackjack'),('xocdia'),('baccarat'),('slot'),('sports'),('lottery')
ON CONFLICT(game_code) DO NOTHING;


-- Thông tin tài khoản ngân hàng dùng cho luồng mô phỏng TEST (không kết nối thanh toán thật).
CREATE TABLE IF NOT EXISTS user_bank_accounts (
 id BIGSERIAL PRIMARY KEY,
 user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 bank_name VARCHAR(120) NOT NULL,
 account_number VARCHAR(64) NOT NULL,
 account_name VARCHAR(120) NOT NULL,
 is_default BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 UNIQUE(user_id, account_number)
);
CREATE INDEX IF NOT EXISTS idx_user_bank_accounts_user ON user_bank_accounts(user_id, is_default DESC, updated_at DESC);

INSERT INTO app_settings(setting_key,setting_value) VALUES
('test_bank_name','NGAN HANG TEST'),
('test_bank_account','0000000000'),
('test_bank_holder','HA88LUCKY TEST'),
('test_bank_note','Chỉ dùng cho mô phỏng TEST - không chuyển tiền thật')
ON CONFLICT(setting_key) DO NOTHING;
