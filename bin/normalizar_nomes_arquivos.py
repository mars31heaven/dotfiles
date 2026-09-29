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
)


def normalize_filename(file_name: str) -> str:
    """
    Corrige sequências comuns de codificação corrompida,
    preservando extensão e demais caracteres válidos.
    """
    corrected_name = file_name

    for corrupted, correct in REPLACEMENTS.items():
        corrected_name = corrected_name.replace(corrupted, correct)

    # Ajustes leves de espaçamento.
    corrected_name = " ".join(corrected_name.split())

    # Mantém espaço antes da extensão fora da normalização.
    suffix = Path(corrected_name).suffix
    stem = Path(corrected_name).stem.strip()

    return f"{stem}{suffix}"


def appears_corrupted(file_name: str) -> bool:
    """
    Identifica se o nome contém indicadores típicos de corrupção.
    """
    return any(marker in file_name for marker in CORRUPTION_MARKERS)


def process_folder(folder: Path, apply_changes: bool) -> None:
    """
    Exibe diagnóstico e, quando solicitado, renomeia os arquivos.
    """
    if not folder.exists():
        print(f"Pasta não encontrada: {folder}")
        return

    if not folder.is_dir():
        print(f"O caminho informado não é uma pasta: {folder}")
        return

    files = sorted(
        [file_path for file_path in folder.iterdir() if file_path.is_file()],
        key=lambda item: item.name.lower(),
    )

    print("=" * 72)
    print("NORMALIZAÇÃO DE NOMES DE ARQUIVOS")
    print("=" * 72)
    print(f"Pasta analisada: {folder}")
    print(f"Arquivos encontrados: {len(files)}")
    print()

    candidates = []

    for file_path in files:
        current_name = file_path.name

        if not appears_corrupted(current_name):
            continue

        corrected_name = normalize_filename(current_name)

        if corrected_name != current_name:
            candidates.append((file_path, corrected_name))

    if not candidates:
        print("Nenhum nome com codificação corrompida foi identificado.")
        return

    print(f"Arquivos identificados para correção: {len(candidates)}")
    print()

    renamed_count = 0
    skipped_count = 0
    error_count = 0

    for current_path, corrected_name in candidates:
        target_path = current_path.with_name(corrected_name)

        print(f"ATUAL: {current_path.name}")
        print(f"NORMALIZADO: {corrected_name}")

        if target_path.exists() and target_path != current_path:
            print("STATUS: IGNORADO — já existe um arquivo com o nome normalizado.")
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
            "Nenhum arquivo foi alterado. "
            "Execute novamente com --apply para confirmar a renomeação."
        )

    print("=" * 72)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Normaliza nomes de arquivos com caracteres corrompidos "
            "por problemas de codificação."
        )
    )

    parser.add_argument(
        "folder",
        help="Caminho da pasta que contém os arquivos a normalizar.",
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
