import pathlib
from subprocess import run
from shutil import copytree, copy, rmtree
import datetime
import os
import pytest


def run_shell(command: str, **kwargs):
    print(f"Run: {command}")
    return run(command, shell=True, check=True, **kwargs)


def build_and_run():
    """Build and run the test program, returning the printed version and commit"""
    run_shell("cmake --build build")
    output = run_shell("build/test_program", capture_output=True, text=True).stdout
    return output.splitlines()


def date_is_today(line):
    return datetime.date.fromisoformat(line[7:]) == datetime.date.today()


@pytest.mark.parametrize("use_submodule", [True, False])
def test_fortran_git(tmp_path, use_submodule):
    # First, set up a fake project by copying this whole project into a temp dir
    test_dir = pathlib.Path(__file__).parent
    fortran_git_dir = test_dir.parent.absolute()
    copied_fortran_git_dir = tmp_path / "fortran-git-version"

    # Create a git repo from our project
    os.chdir(tmp_path)
    run_shell("git init")

    if use_submodule:
        run_shell(f"git submodule add {fortran_git_dir} fortran-git-version")
    else:
        copytree(fortran_git_dir, copied_fortran_git_dir, dirs_exist_ok=True)
        rmtree(copied_fortran_git_dir / ".git", ignore_errors=True)
        rmtree(copied_fortran_git_dir / "build", ignore_errors=True)

    # We use the test program and CMake files as the basis of our fake project
    copy(test_dir / "CMakeLists.txt", tmp_path)
    copy(test_dir / "test_program.f90", tmp_path)

    run_shell("git add --all")
    run_shell('git commit -m "Initial commmit"')
    run_shell("git tag v1.2.3")
    commit = run_shell("git rev-parse HEAD", capture_output=True, text=True).stdout

    # Configure the fake project
    run_shell("cmake . -B build")

    # Run the test program and extract the printed version and commit
    version_line, commit_line, date_line = build_and_run()

    assert version_line.strip() == "Version: v1.2.3"
    assert commit_line.strip() == f"Latest commit: {commit[:7]}"
    assert date_is_today(date_line)

    # Add a couple more commits to check the program gets rebuilt and
    # the git info updated
    run_shell("git commit -m 'Empty commit' --allow-empty")
    run_shell("git commit -m 'Empty commit' --allow-empty")
    commit = run_shell("git rev-parse HEAD", capture_output=True, text=True).stdout

    version_line, commit_line, date_line = build_and_run()

    assert version_line.strip() == f"Version: v1.2.3-2-g{commit[:7]}"
    assert commit_line.strip() == f"Latest commit: {commit[:7]}"
    assert date_is_today(date_line)

    run_shell("echo ' ' >> test_program.f90")
    version_line, commit_line, date_line = build_and_run()

    assert version_line.strip() == f"Version: v1.2.3-2-g{commit[:7]}-dirty"
    assert commit_line.strip() == f"Latest commit: {commit[:7]}"
    assert date_is_today(date_line)
