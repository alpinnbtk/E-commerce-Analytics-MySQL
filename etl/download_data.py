from pathlib import Path

from kaggle.api.kaggle_api_extended import KaggleApi

DATASET = "olistbr/brazilian-ecommerce"
RAW_DIR = Path("data/raw")


def main() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    api = KaggleApi()
    api.authenticate()  
    api.dataset_download_files(DATASET, path=str(RAW_DIR), unzip=True, quiet=False)

    files = sorted(RAW_DIR.glob("*.csv"))
    print(f"\n{len(files)} file CSV di {RAW_DIR}:")
    for f in files:
        print(f"  {f.name:45s} {f.stat().st_size / 1_048_576:6.1f} MB")


if __name__ == "__main__":
    main()