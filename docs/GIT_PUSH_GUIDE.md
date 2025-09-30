# GitHub 提交指南

## 当前状态
- 本地 Git 仓库已初始化 ✅
- 所有文件已添加到暂存区 ✅
- 已创建初始提交 ✅
- 远程仓库已添加：git@github.com:ZIS-SUN/classroom.git ✅

## 提交到 GitHub 的步骤

### 方法一：强制推送（推荐 - 如果远程仓库内容可以覆盖）

```bash
# 1. 进入项目目录
cd /Users/zishen/Desktop/classroom-main

# 2. 强制推送到 GitHub（会覆盖远程仓库）
git push -u origin main --force
```

### 方法二：如果推送超时，增加缓冲区

```bash
# 1. 设置更大的缓冲区
git config http.postBuffer 524288000

# 2. 再次尝试推送
git push -u origin main --force
```

### 方法三：如果网络不稳定，可以分步推送

```bash
# 1. 先推送部分文件
git push origin main:refs/heads/main --force

# 2. 如果失败，可以尝试使用 HTTP 而不是 SSH
git remote set-url origin https://github.com/ZIS-SUN/classroom.git
git push -u origin main --force
```

### 方法四：处理远程冲突（如果需要保留远程内容）

```bash
# 1. 拉取远程内容并合并
git pull origin main --allow-unrelated-histories --no-rebase

# 2. 如果有冲突，手动解决冲突后
git add .
git commit -m "Merge remote changes"

# 3. 推送
git push -u origin main
```

## 常见问题

### 问题1：推送超时
**原因**：网络不稳定或文件太大
**解决**：
- 检查网络连接
- 使用方法二增加缓冲区
- 尝试使用 HTTPS 代替 SSH

### 问题2：远程仓库有冲突
**原因**：远程仓库已有内容
**解决**：
- 使用 `--force` 强制覆盖（方法一）
- 或使用方法四合并远程内容

### 问题3：SSH 认证失败
**原因**：SSH 密钥未配置
**解决**：
```bash
# 测试 SSH 连接
ssh -T git@github.com

# 如果失败，切换到 HTTPS
git remote set-url origin https://github.com/ZIS-SUN/classroom.git
```

## 验证推送成功

推送成功后，访问以下网址确认：
https://github.com/ZIS-SUN/classroom

## 后续提交

以后修改代码后提交：

```bash
# 1. 查看修改状态
git status

# 2. 添加修改的文件
git add .

# 3. 提交修改
git commit -m "描述你的修改"

# 4. 推送到 GitHub
git push origin main
```

## 当前 Git 配置信息

- **本地分支**：main
- **远程仓库**：git@github.com:ZIS-SUN/classroom.git
- **提交数量**：1 个提交（149 个文件，32805 行代码）

## 注意事项

1. 首次推送建议使用 `--force`，因为远程仓库已有内容
2. node_modules 和 target 等目录已被 .gitignore 忽略
3. 推送可能需要 1-5 分钟，请耐心等待
4. 确保网络连接稳定