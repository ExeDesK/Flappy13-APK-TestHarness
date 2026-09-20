# Flappy Bird 1.3 — APK Test Harness

[English version](README.en.md)

Harness de test déterministe pour comparer **tick par tick** un APK Android 1.3 fourni localement par l'utilisateur avec une réimplémentation PWA.

> Ce dépôt ne contient **aucun APK**, aucun asset du jeu, aucun son, aucune bibliothèque native et aucune clé de signature. Il contient uniquement l'instrumentation, les scripts de test et des traces numériques de référence.

## Référence

```text
APK : Flappy Bird 1.3
SHA-256 : A3E6958CE2100966F4E207778E4CDBE72788214148C7F4BFD042BA365498DEB3
Android : 4.4.2
API : 19
ABI : x86
```

La convention temporelle est :

```text
input du tick N
→ simulation du tick N
→ S,N = état après simulation du tick N
```

## Suite canonique

| Scénario | Objectif | Fin attendue |
|---|---|---|
| `01-ground` | lancement puis chute | sol, tick 53, score 0 |
| `02-score10` | passer 10 tuyaux | tuyau bas, tick 953, score 10 |
| `03-sky-pipe` | montée répétée | tuyau haut, tick 224, score 0 |
| `04-long20` | partie longue | tuyau bas, tick 1733, score 20 |

Les quatre traces APK de référence sont versionnées dans `golden/apk/` et protégées par les empreintes de `golden/manifest.json`.

## Prérequis

Pour **construire** l'APK instrumentée :

- Java / JDK (`java`, `keytool`, `jarsigner`) ;
- Python 3 ;
  - sous Windows, le script détecte `python`, `py -3` ou `python3` et ignore les faux alias Microsoft Store non fonctionnels ;
- connexion Internet au premier build pour télécharger apktool 2.9.3.

Pour **exécuter** les tests :

- Android SDK Platform Tools (`adb`) ;
- un émulateur Android 4.4.2 / API 19 / x86 ;
- Node.js 18+ pour la validation des traces et la comparaison PWA.

Le script de build vérifie par défaut que l'APK fourni correspond exactement au SHA-256 de référence.

## Windows

### 1. Construire l'APK instrumentée

Place l'APK original à côté du dépôt, puis :

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\build-instrumented.ps1 -Apk .\FlappyBird-1.3.apk
```

Sortie :

```text
out\FlappyBird-1.3-instrumented.apk
```

### 2. Installer

```powershell
.\install.ps1 -UninstallOriginal
```

L'APK instrumentée est signée avec une clé de test locale différente de la signature originale ; l'application originale doit donc être désinstallée avant l'installation de la version instrumentée.

### 3. Lancer la suite

```powershell
.\run-suite.ps1
```

À chaque scénario : lorsque le menu apparaît, clique **une seule fois sur PLAY**, puis ne touche plus l'écran.

## Linux

### 1. Construire

```bash
chmod +x *.sh
./build-instrumented.sh ./FlappyBird-1.3.apk
```

### 2. Installer

```bash
./install.sh --uninstall-original
```

### 3. Lancer la suite

```bash
./run-suite.sh
```

## Lancer un seul scénario

Windows :

```powershell
.\run-scenario.ps1 -Name 03-sky-pipe
```

Linux :

```bash
./run-scenario.sh 03-sky-pipe
```

Les captures locales sont archivées dans :

```text
traces/apk/<scenario>/<timestamp>.csv
traces/apk/<scenario>/latest.csv
```

`traces/` est ignoré par Git. Les seules traces versionnées sont les golden traces sous `golden/`.

## Comparer avec la PWA

Le repo PWA attendu doit contenir :

```text
site/src/game.js
```

Windows :

```powershell
.\compare-suite.ps1 -PwaRepo C:\dev\FlappyBird-PWA
```

Linux :

```bash
./compare-suite.sh /home/user/dev/FlappyBird-PWA
```

Le script :

1. rejoue les quatre scénarios dans le moteur PWA ;
2. génère `traces/pwa/*.csv` ;
3. compare chaque état à la trace APK correspondante ;
4. compare les champs de physique flottants en **float32 bit à bit**.

Un résultat valide ressemble à :

```text
MATCH: 1734 ticks, 38148 values, 0 differences
```

## Vérifier les golden traces

Aucune dépendance npm n'est nécessaire :

```bash
npm test
```

Cela vérifie :

- le SHA-256 des quatre golden traces ;
- seed et inputs ;
- tick terminal ;
- score ;
- type de collision ;
- nombre de lignes d'état.

## Structure

```text
.
├── .github/workflows/ci.yml
├── docs/
├── examples/
├── golden/
│   ├── apk/
│   └── manifest.json
├── patches/
│   └── TestHarness.smali
├── scenarios/
├── tools/
├── traces/                 # généré localement, ignoré par Git
├── build-instrumented.ps1
├── build-instrumented.sh
├── install.ps1
├── install.sh
├── run-replay.ps1
├── run-replay.sh
├── run-scenario.ps1
├── run-scenario.sh
├── run-suite.ps1
├── run-suite.sh
├── compare-suite.ps1
└── compare-suite.sh
```

## Fonctionnement de l'instrumentation

Le build local :

1. vérifie le hash de l'APK fourni ;
2. télécharge et vérifie apktool 2.9.3 ;
3. décode l'APK ;
4. injecte `TestHarness.smali` ;
5. force la seed RNG uniquement lorsque le mode test est activé ;
6. injecte les taps aux ticks demandés via le chemin d'input original, au point neutre `(144,256)` ;
7. journalise l'état après chaque tick ;
8. recompile et signe localement l'APK de test.

Sans extras `flappy_test`, l'instrumentation reste inactive.

## Documentation

- [Environnement de référence](docs/REFERENCE_ENVIRONMENT.md)
- [Format des traces](docs/TRACE_FORMAT.md)
- [Contrat de validation](docs/VALIDATION.md)

## Note projet

Outil non officiel destiné au reverse-engineering, au test de compatibilité et à la validation déterministe. Le dépôt ne distribue pas l'application originale.
