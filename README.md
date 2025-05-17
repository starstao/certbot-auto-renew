## 使用 Let's Encrypt 申请免费泛域名 SSL 证书，并实现自动续期
仅支持使用腾讯云的DNS实现自动续期，如果要支持其他厂商的DNS，请修改dnspod.sh脚本以适配  
只有当前在机器上申请了证书才能在当前机器执行续期操作
更多Let‘s Encrypt获取免费SSL证书请[查看博客](https://starstao.com/2025/05/use-lets-encrypt-to-get-free-ssl-certificates-and-auto-renew-with-scripts-on-tencent-cloud)
### 前置条件
安装docker  
`sudo apt install docker-compose-v2`  
安装certbot  
`sudo snap install --classic certbot`  
拉取腾讯云 CLI 工具docker镜像，我们使用docker镜像中的命令开箱即用避免复杂的安装流程  
`docker pull tencentcom/tencentcloud-cli`  
tccli安装和使用参考  
https://cloud.tencent.com/product/cli
### 使用方法
1. git clone https://github.com/starstao/certbot-auto-renew
2. cd certbot-auto-renew
3. 编辑dnspod.env文件，填写腾讯云的API鉴权密钥，申请地址：https://console.cloud.tencent.com/cam/capi    
   点击新建密钥后，会出现如下提示  
```
   为降低密钥泄漏的风险，自2023年11月30日起，新建的密钥只在创建时提供SecretKey，后续不可再进行查询，请保存好SecretKey。
   SecretId xxxxxxxxxxx
   SecretKey xxxxxxxxxx
```
   dnspod.env中的secretId填写提示的SecretId  
   SecretKey填写SecretKey  
   例如  
```
   secretId=xxxxxxxxxxx
   secretKey=xxxxxxxxxxx
```
4. 编辑replace_certs_and_reload_service.sh脚本  
将`rsync -avPL /etc/letsencrypt/live/ /opt/ssl/certs/`  
中的改为/opt/ssl/certs/
你想要存放证书的地址，自动续期完成后，将证书拷贝到/opt/ssl/certs/目录  
将`cd /opt/nginx/ && docker compose stop && docker compose start`  
命令替换为你想要重启的服务的命令，我这里是用的nginx，目录在/opt/nginx/,切换过去执行了docker compose stop && docker compose start命令去重启它
5. chmod +x *.sh, ./force_renew.sh example.com是强制续期命令, ./renew.sh 是自动续期命令，快到期一个月前自动续期否则不会续期
6. 设置定时任务  
  `apt install cron`安装crontab  
  `systemctl status cron`查看服务是否在运行  
  `crontab -e`编辑crontab添加如下命令  
```
# 五个星号分别代表分钟、小时、日、月、周
0 21 * * 5 /opt/ssl/script/renew.sh
```
  每周五晚上九点定时执行