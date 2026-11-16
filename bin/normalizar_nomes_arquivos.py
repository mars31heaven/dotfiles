from __future__ import annotations

import argparse
from pathlib import Path


# ============================================================
# MAPEAMENTO DE CARACTERES CORROMPIDOS
# ============================================================

REPLACEMENTS = {
    # Sequências compostas mais específicas devem vir primeiro.
    "├з├г": "çã",
    "├з├╡": "çõ",
    "├з├┤": "çó",
    "├з├й": "çé",
    "├з├н": "çí",
    "├з├║": "çú",

    # Vogais com acento ou circunflexo.
    "├б": "á",
    "├í": "á",
    "├г": "ã",
    "├в": "â",
    "├а": "à",
    "├й": "é",
    "├к": "ê",
    "├н": "í",
    "├│": "ó",
    "├┤": "ó",
    "├╢": "ô",
    "├║": "ú",

    # Caractere cirílico usado indevidamente no lugar de Ó.
    "У": "Ó",

    # Cedilha e combinações residuais.
    "├з": "ç",
    "├╡": "õ",

    # Aspas e caracteres frequentes em nomes de arquivo.
    "ÔÇô": "-",
    "ÔÇö": "-",
    "ÔÇ£": '"',
    "ÔÇ¥": '"',
    "ÔÇÖ": "'",
    "Â": "",

    # Último recurso: remove o marcador residual.
    "├": "",
}


# Marcadores usados apenas para detectar nomes potencialmente corrompidos.
CORRUPTION_MARKERS = (
    "├",
    "ÔÇ",
    "Â",
    "�",
    "У",
)


def normalize_name(name: str, is_file: bool) -> str:
    """
    Corrige sequências comuns de codificação corrompida.

    Para arquivos, preserva a extensão.
    Para diretórios, normaliza o nome completo.
    """
    corrected_name = name

    for corrupted, correct in REPLACEMENTS.items():
        corrected_name = corrected_name.replace(corrupted, correct)

    # Remove espaços repetidos e espaços no início/fim.
    corrected_name = " ".join(corrected_name.split())

    if not is_file:
        return corrected_name.strip()

    suffix = Path(corrected_name).suffix
    stem = Path(corrected_name).stem.strip()

    return f"{stem}{suffix}"


def appears_corrupted(name: str) -> bool:
    """
    Identifica se o nome contém indicadores típicos de corrupção.
    """
    return any(marker in name for marker in CORRUPTION_MARKERS)


def get_entries_recursively(folder: Path) -> list[Path]:
    """
    Retorna todos os arquivos e diretórios abaixo da pasta principal.

    A ordenação por profundidade, da maior para a menor, garante que
    arquivos e subdiretórios sejam processados antes de seus diretórios-pai.
    """
    entries = list(folder.rglob("*"))

    return sorted(
        entries,
        key=lambda path: (len(path.parts), path.name.lower()),
        reverse=True,
    )


def process_folder(folder: Path, apply_changes: bool) -> None:
    """
    Exibe diagnóstico e, quando solicitado, renomeia arquivos e diretórios.
    """
    if not folder.exists():
        print(f"Pasta não encontrada: {folder}")
        return

    if not folder.is_dir():
        print(f"O caminho informado não é uma pasta: {folder}")
        return

    entries = get_entries_recursively(folder)

    files = [path for path in entries if path.is_file()]
    directories = [path for path in entries if path.is_dir()]

    print("=" * 72)
    print("NORMALIZAÇÃO RECURSIVA DE NOMES")
    print("=" * 72)
    print(f"Pasta analisada: {folder}")
    print(f"Arquivos encontrados: {len(files)}")
    print(f"Diretórios encontrados: {len(directories)}")
    print()

    candidates: list[tuple[Path, str]] = []

    for path in entries:
        current_name = path.name

        if not appears_corrupted(current_name):
            continue

        corrected_name = normalize_name(
            name=current_name,
            is_file=path.is_file(),
        )

        if corrected_name and corrected_name != current_name:
            candidates.append((path, corrected_name))

    if not candidates:
        print("Nenhum nome com codificação corrompida foi identificado.")
        return

    print(f"Itens identificados para correção: {len(candidates)}")
    print()

    renamed_count = 0
    skipped_count = 0
    error_count = 0

    for current_path, corrected_name in candidates:
        target_path = current_path.with_name(corrected_name)

        item_type = "DIRETÓRIO" if current_path.is_dir() else "ARQUIVO"

        print(f"TIPO: {item_type}")
        print(f"ATUAL: {current_path.name}")
        print(f"NORMALIZADO: {corrected_name}")
        print(f"LOCAL: {current_path.parent}")

        if target_path.exists() and target_path != current_path:
            print("STATUS: IGNORADO — já existe um item com o nome normalizado.")
            print()
            skipped_count += 1
            continue

        if not apply_changes:
            print("STATUS: PRÉVIA — nenhuma alteração foi feita.")
            print()
            continue

        try:
            current_path.rename(target_path)
            print("STATUS: RENOMEADO COM SUCESSO.")
            print()
            renamed_count += 1

        except OSError as error:
            print(f"STATUS: ERRO — {error}")
            print()
            error_count += 1

    print("=" * 72)

    if apply_changes:
        print("RESULTADO FINAL")
        print(f"Renomeados: {renamed_count}")
        print(f"Ignorados: {skipped_count}")
        print(f"Erros: {error_count}")
    else:
        print("RESULTADO DA PRÉVIA")
        print(
            "Nenhum item foi alterado. "
            "Execute novamente com --apply para confirmar a renomeação."
        )

    print("=" * 72)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Normaliza recursivamente nomes de arquivos e diretórios "
            "com caracteres corrompidos por problemas de codificação."
        )
    )

    parser.add_argument(
        "folder",
        help="Caminho da pasta principal a normalizar recursivamente.",
    )

    parser.add_argument(
        "--apply",
        action="store_true",
        help="Aplica a renomeação. Sem esta opção, o script apenas mostra a prévia.",
    )

    args = parser.parse_args()

    input_folder = Path(args.folder).expanduser().resolve()

    process_folder(
        folder=input_folder,
        apply_changes=args.apply,
    )


if __name__ == "__main__":
    main()
