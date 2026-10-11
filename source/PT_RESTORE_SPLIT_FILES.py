#!/usr/bin/env python3
"""Restore every split file from its .parts/ directory, verifying original SHA256.
Run: python source/PT_RESTORE_SPLIT_FILES.py --repo-root .
"""
import argparse, csv, hashlib, os
from pathlib import Path

CHUNK_BYTES=1024*1024

def restore(repo_root: Path) -> None:
    repo_root=repo_root.resolve()
    manifest=repo_root/'source/PT_EXACT_ZIP_MANIFEST.csv'
    if not manifest.is_file():
        raise FileNotFoundError(manifest)
    total=0
    with manifest.open('r',encoding='utf-8',newline='') as fh:
        for row in csv.DictReader(fh):
            if row['storage'] != 'split-git-parts':
                continue
            rel=row['git_or_archive_path']
            if (not rel.startswith('source/PT/') or rel.startswith('/')
                    or any(p in ('','.','..') for p in rel.split('/'))):
                raise RuntimeError('Invalid output path: '+repr(rel))
            output=repo_root.joinpath(*rel.split('/'))
            if not output.resolve().is_relative_to(repo_root):
                raise RuntimeError('Unsafe path: '+rel)
            partsdir=Path(str(output)+'.parts')
            parts=sorted(partsdir.glob('part-*.bin'))
            if not parts:raise RuntimeError('No part files for '+rel)
            output.parent.mkdir(parents=True,exist_ok=True)
            tmp=output.with_name(output.name+'.restore-incomplete')
            sha=hashlib.sha256(); size=0
            try:
                with tmp.open('wb') as dst:
                    for expected_index,part in enumerate(parts):
                        if part.name != f'part-{expected_index:04d}.bin':
                            raise RuntimeError('Part number gap: '+rel)
                        with part.open('rb') as source:
                            while True:
                                chunk=source.read(CHUNK_BYTES)
                                if not chunk:break
                                dst.write(chunk);sha.update(chunk);size+=len(chunk)
                if size!=int(row['uncompressed_bytes']) or sha.hexdigest()!=row['sha256']:
                    raise RuntimeError('Original SHA256/size differs: '+rel)
                os.replace(tmp,output)
            finally:
                if tmp.exists():tmp.unlink()
            total+=1
            print('RESTORED:',rel,'|',size,'bytes | SHA256 OK')
    print('DONE:',total,'split files restored byte-for-byte')

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--repo-root',type=Path,default=Path('.'))
    args=p.parse_args()
    restore(args.repo_root)
