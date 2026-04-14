# kassenrechner

Flutter Kassenrechner als Web-App.

## Deployment auf GitHub Pages (eigenes Repo)

Dieser Branch enthält einen Workflow unter `.github/workflows/deploy-pages.yml`, der bei jedem Push auf `main` automatisch nach GitHub Pages deployed.

1. Repository nach GitHub pushen (z. B. `kassenrechner`).
2. In GitHub unter `Settings > Pages` bei `Build and deployment` die Quelle auf `GitHub Actions` setzen.
3. Auf den ersten Workflow-Run warten.

Die App ist danach unter folgender URL erreichbar:

`https://<USERNAME>.github.io/<REPO-NAME>/`
