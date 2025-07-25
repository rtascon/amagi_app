#!/usr/bin/env python3
import sys, re, shutil, time
from pathlib import Path

DESIRED_INFO_PLIST = "Runner/Info.plist"

def main():
    if len(sys.argv) != 2:
        print("Uso: python3 fix_infoplist.py [ruta-ios]")
        sys.exit(1)

    input_path = Path(sys.argv[1]).expanduser().resolve()
    if not input_path.exists():
        print(f"ERROR: No existe: {input_path}")
        sys.exit(1)

    if input_path.is_dir() and input_path.suffix == ".xcodeproj":
        proj_dir = input_path
    elif input_path.is_dir():
        candidates = list(input_path.glob("**/Runner.xcodeproj"))
        if not candidates:
            print("ERROR: No se encontró Runner.xcodeproj.")
            sys.exit(1)
        proj_dir = candidates[0]
    else:
        print("ERROR: Ruta inválida.")
        sys.exit(1)

    pbxproj = proj_dir / "project.pbxproj"
    if not pbxproj.exists():
        print(f"ERROR: No se encontró {pbxproj}")
        sys.exit(1)

    print(f"-> Editando: {pbxproj}")

    txt = pbxproj.read_text(encoding="utf-8")
    ts = time.strftime("%Y%m%d-%H%M%S")
    backup = pbxproj.with_suffix(f".pbxproj.bak-{ts}")
    shutil.copy2(pbxproj, backup)
    print(f"   Backup creado: {backup.name}")

    pattern_buildfile = re.compile(r'\s*[0-9A-F]{24} /\* Info\.plist in Resources \*/ = \{[^}]*\};\n', flags=re.IGNORECASE)
    txt, n1 = pattern_buildfile.subn('', txt)

    pattern_resource_ref = re.compile(r'\s*[0-9A-F]{24} /\* Info\.plist in Resources \*/,\n', flags=re.IGNORECASE)
    txt, n2 = pattern_resource_ref.subn('', txt)

    def repl_infoplist(m):
        val = m.group(1).strip()
        return f"INFOPLIST_FILE = {DESIRED_INFO_PLIST};" if val != DESIRED_INFO_PLIST else m.group(0)

    pattern_infoplist = re.compile(r'INFOPLIST_FILE = ([^;]+);')
    txt, n3 = pattern_infoplist.subn(repl_infoplist, txt)

    pbxproj.write_text(txt, encoding="utf-8")
    print(f"-> Cambios: {n1} entradas PBXBuildFile eliminadas, {n2} refs de recursos eliminadas, {n3} ajustes de INFOPLIST_FILE.")
    print("Hecho.")
if __name__ == "__main__":
    main()
