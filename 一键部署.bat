rem 清理原来的文件
call npx hexo clean
rem 生成静态文件
call npx hexo generate
rem 开始部署本地服务器
call npx hexo server
rem 打开主页
public/index.html