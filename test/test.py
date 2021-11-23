import pathlib
from subprocess import run
from shutil import copytree, copy, rmtree
import os


def run_shell(command: str, **kwargs):
    return run(command, shell=True, check=True, **kwargs)


def test_fortran_git(tmp_path):
    # First, set up a fake project by copying this whole project into a temp dir
    test_dir = pathlib.Path(__file__).parent
    fortran_git_dir = test_dir.parent
    copied_fortran_git_dir = tmp_path / "fortran-git-version"

    copytree(fortran_git_dir, copied_fortran_git_dir, dirs_exist_ok=True)
    rmtree(copied_fortran_git_dir / ".git", ignore_errors=True)
    rmtree(copied_fortran_git_dir / "build", ignore_errors=True)

    # We use the test program and CMake files as the basis of our fake project
    copy(test_dir / "CMakeLists.txt", tmp_path)
    copy(test_dir / "test_program.f90", tmp_path)

    # Now we need to create a git repo from our project, including a tag
    os.chdir(tmp_path)
    run_shell("git init")
    run_shell("git add --all")
    run_shell('git commit -m "Initial commmit"')
    run_shell("git tag v1.2.3")
    commit = run_shell("git rev-parse HEAD", capture_output=True, text=True).stdout

    # Build the fake project
    run_shell("cmake . -B build")
    run_shell("cmake --build build")

    # Run the test program and extract the printed version and commit
    output = run_shell("build/test_program", capture_output=True, text=True).stdout
    version_line, commit_line = output.splitlines()

    assert version_line.strip() == "Version: v1.2.3"
    assert commit_line.strip() == f"Latest commit: {commit[:7]}"

    # Add a couple more commits to check the program gets rebuilt and
    # the git info updated
    run_shell("git commit -m 'Empty commit' --allow-empty")
    run_shell("git commit -m 'Empty commit' --allow-empty")
    commit = run_shell("git rev-parse HEAD", capture_output=True, text=True).stdout

    run_shell("cmake --build build")

    output = run_shell("build/test_program", capture_output=True, text=True).stdout
    version_line, commit_line = output.splitlines()

    assert version_line.strip() == f"Version: v1.2.3-2-g{commit[:7]}"
    assert commit_line.strip() == f"Latest commit: {commit[:7]}"
