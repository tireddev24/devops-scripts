from datetime import datetime
from pathlib import Path
import tarfile
import argparse
import sys




def make_backup(src: Path, dest: Path) -> Path:

	dest.mkdir(parents=True, exist_ok=True)
	stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
	archive = dest / f"{src.name}-{stamp}.tar.gz"

	tmp = dest / f".partial-{stamp}"


	try:
	    with tarfile.open(tmp, "w:gz") as tar:
	        tar.add(src, arcname=src.name)
	    tmp.rename(archive)
	    return archive
	finally:
	    tmp.unlink(missing_ok=True)
	

def rotate(src: Path, dest: Path, keep:int) -> None:
	archives = sorted(
	    dest.glob(f"{src.name}-*.tar.gz"),
	    key=lambda p: p.stat().st_mtime,
	    reverse=True,
	)

	for old in archives[keep:]:
	    old.unlink()

def main() -> int:
	parser = argparse.ArgumentParser(description="Back up a directory with rotation.")
	parser.add_argument("source", type=Path)
	parser.add_argument("--keep", type=int, default=3)
	parser.add_argument("--dest", type=Path, default=Path.home() / "backups")
	args=parser.parse_args()

	if not args.source.is_dir():
		print(f"ERROR: {args.source} is not a directory", file=sys.stderr)
		return 2

	if args.keep < 1:
	    print("ERROR: --keep must be at least 1", file=sys.stderr)
	    return 2

	archive = make_backup(args.source, args.dest)
	print(f"Created {archive}")
	rotate(args.source,args.dest, args.keep)
	return 0


if __name__ == "__main__":
	sys.exit(main())



















