# Web Project Deployment Workflow
(Local -> GitHub -> Cloudflare Pages)

このドキュメントは、ローカルで作成したWebプロジェクトをGitHubで管理し、Cloudflare Pages経由で自動デプロイまでする手順をまとめたものです。

---

## 1. ローカルでのプロジェクト作成と構成

モダンなWeb開発では、「開発用コード（Source）」と「本番用コード（Build/Dist）」を明確に分けます。

### ディレクトリ構成の考え方

*   **`src/` (開発用)**: 人間が読み書きするコード。GitHubで管理します。
*   **`dist/` (本番用)**: `npm run build` コマンドで自動生成される、圧縮・最適化されたコード。**GitHubには上げません**。

> **なぜ `dist` を分けるのか？**
> `dist` の中身は機械的に生成されるため、人間が管理する必要がありません。詳細な「開発用」と「本番用」の区別は、バグの混入を防ぎ、Gitの履歴をきれいに保つために重要です。

### .gitignore の設定

プロジェクトルートにある `.gitignore` ファイルに以下が含まれていることを確認します。

```text
node_modules
dist
.DS_Store
```

---

## 2. GitHubでの管理 (Push)

ローカルのソースコードをGitHubにアップロードします。

1.  **GitHubで新規リポジトリ作成**
    *   Repository nameを入力（例: `my-new-project`）。
    *   Public/Privateを選択。
    *   「Create repository」をクリック。

2.  **ローカルからPush**
    ターミナルでプロジェクトのディレクトリに移動し、以下のコマンドを実行します。

    ```bash
    # 初回のみ
    git init
    git add .
    git commit -m "first commit"
    git branch -M master
    git remote add origin git@github.com:USERNAME/REPO_NAME.git
    git push -u origin master
    ```

    以降の更新は：
    ```bash
    git add .
    git commit -m "update message"
    git push
    ```

---

## 3. Cloudflare Pages の作成 (Deploy)

Cloudflare側に「GitHubのこのリポジトリのコードを使って、自動でビルド・公開してね」と設定します。

1.  **Cloudflare Dashboard** にログイン。
2.  左メニュー **Workers & Pages** > **Create Application** > **Create** > **Connect to Git** をクリック。
3.  GitHubアカウントを連携し、リポジトリを選択して **Begin setup**。

### Build Settings (重要)

ここが間違っているとデプロイに失敗します。

*   **Project name**: 任意のプロジェクト名（URLになります）。
*   **Production branch**: `master` (または `main`)。
*   **Framework preset**: `Vite` (Next.jsなら `Next.js` など)。
*   **Build command**: `npm run build`
*   **Build output directory**: **`dist`** (Viteの場合)
*   **Root directory**: プロジェクトがルートにあるなら空欄 (`/`)。サブフォルダにある場合のみ記述。

**Save and Deploy** をクリックすると、自動デプロイが完了します。

---

## 4. Custom Domain の設定

デフォルトの `xxxx.pages.dev` ではなく、独自のドメイン（例: `fil-tokyo.com`）で公開する設定です。

1.  Cloudflare Pagesのプロジェクト詳細画面へ移動。
2.  **Custom domains** タブ > **Set up a custom domain**。
3.  ドメイン名（例: `fil-tokyo.com`）を入力して **Continue**。
4.  CloudflareがDNS設定を提案するので、**Activate Domain** をクリック。

---

## 今後の更新フロー

一度この設定を行えば、運用は非常にシンプルになります。

1.  ローカルでコードを編集 (`src/` 内)。
2.  **git push** する。
3.  Cloudflareが自動で検知し、数分で本番環境が更新されます。
