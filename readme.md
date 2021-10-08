# Laravel AWS Small Environment Skeleton

LaravelをAWSで動かすためのスケルトンです。
appサーバーとDBサーバーの２台厚生です。

（TODO 構成図）

## 利用方法

クローンする

```bash
git clone --depth 1 https://github.com/t-kuni/laravel-aws-small-environment-skeleton.git [FOLDER_NAME]
cd [FOLDER_NAME]
rm -rf .git
```


AWSのtfstateをバックアップするためのバケットを用意する  
※暗号化、バージョニングを有効化するのがオススメ

`main.tf`のbucketを上記のバケットに書き換える

変数ファイルをコピーする

```
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

terraformを初期化する

```
terraform init
```

`variables.tf`のプロジェクト名(`project_name`)を変更する  
（使わないなら削除しても良い）

初回起動時はDB用のディスクのマウントに失敗します  
ファイルシステムを作成してから再マウントして下さい  
この手順を忘れてDBにデータを保存しても、エフェメラルディスクに保存され、インスタンスを削除した際にDBのデータも削除されてしまいます