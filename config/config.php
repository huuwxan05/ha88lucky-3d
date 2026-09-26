<?php
declare(strict_types=1);
function envv(string $k, ?string $d=null): ?string { $v=getenv($k); return ($v===false||$v==='')?$d:$v; }
return ['app'=>['env'=>envv('APP_ENV','production'),'name'=>envv('APP_NAME','ROYAL ONLINE'),'session_name'=>envv('SESSION_NAME','royal_session')],'db'=>['url'=>envv('DATABASE_URL',''),'host'=>envv('DB_HOST','127.0.0.1'),'port'=>envv('DB_PORT','5432'),'name'=>envv('DB_NAME','royal_online'),'user'=>envv('DB_USER','royal_user'),'pass'=>envv('DB_PASS',''),'sslmode'=>envv('DB_SSLMODE','require')]];
