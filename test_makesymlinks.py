"""Tests for makesymlinks."""

import os
import importlib.util
import importlib.machinery
from unittest.mock import patch
import pytest

# Load makesymlinks as a module (it has no .py extension)
_script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "makesymlinks")
_loader = importlib.machinery.SourceFileLoader("makesymlinks_mod", _script_path)
spec = importlib.util.spec_from_loader("makesymlinks_mod", _loader)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

makesymlinks = mod.makesymlinks
setup_tmux = mod.setup_tmux


@pytest.fixture
def setup_env(tmp_path, monkeypatch):
    """Create a fake HOME and rcs directory for testing."""
    home = tmp_path / "home"
    home.mkdir()
    rcs = tmp_path / "rcs"
    rcs.mkdir()
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.setenv("RCS_PATH", str(rcs))
    # Patch setup_tmux so symlink tests don't trigger git clone
    with patch.object(mod, "setup_tmux"):
        yield home, rcs


def _make_logger():
    import logging
    logger = logging.getLogger("test_makesymlinks")
    logger.setLevel(logging.DEBUG)
    return logger


class TestBasicSymlinking:
    """Test the core symlink creation behavior."""

    def test_creates_symlink_for_regular_file(self, setup_env):
        home, rcs = setup_env
        (rcs / ".vimrc").write_text("set nocompatible")

        makesymlinks(_make_logger())

        link = home / ".vimrc"
        assert link.is_symlink()
        assert os.readlink(str(link)) == str(rcs / ".vimrc")

    def test_creates_symlinks_for_multiple_files(self, setup_env):
        home, rcs = setup_env
        (rcs / ".bashrc").write_text("# bash")
        (rcs / ".vimrc").write_text("# vim")

        makesymlinks(_make_logger())

        assert (home / ".bashrc").is_symlink()
        assert (home / ".vimrc").is_symlink()


class TestSkipBehavior:
    """Test cases where makesymlinks should skip files."""

    def test_skips_existing_symlink(self, setup_env):
        home, rcs = setup_env
        (rcs / ".bashrc").write_text("# new")
        # Create an existing symlink pointing somewhere else
        other = home / "other"
        other.write_text("# other")
        (home / ".bashrc").symlink_to(str(other))

        makesymlinks(_make_logger())

        # Should still point to the original target, not rcs
        assert os.readlink(str(home / ".bashrc")) == str(other)

    def test_skips_existing_directory(self, setup_env):
        home, rcs = setup_env
        (rcs / ".config").write_text("# config file")
        # Create a directory with the same name in HOME
        (home / ".config").mkdir()

        makesymlinks(_make_logger())

        # Directory should still be a directory, not replaced
        assert (home / ".config").is_dir()
        assert not (home / ".config").is_symlink()

    def test_skips_subdirectories_in_rcs(self, setup_env):
        home, rcs = setup_env
        subdir = rcs / "subdir"
        subdir.mkdir()
        (subdir / "nested.conf").write_text("# nested")
        (rcs / ".bashrc").write_text("# bash")

        makesymlinks(_make_logger())

        # Only .bashrc should be linked, not the subdir or its contents
        assert (home / ".bashrc").is_symlink()
        assert not (home / "subdir").exists()
        assert not (home / "nested.conf").exists()


class TestBackupBehavior:
    """Test that existing regular files are backed up before symlinking."""

    def test_backs_up_existing_file(self, setup_env):
        home, rcs = setup_env
        (rcs / ".bashrc").write_text("# new config")
        (home / ".bashrc").write_text("# old config")

        makesymlinks(_make_logger())

        # Original file should be backed up
        backup = home / ".bashrc.bak"
        assert backup.exists()
        assert backup.read_text() == "# old config"
        # New symlink should exist
        assert (home / ".bashrc").is_symlink()

    def test_backup_preserves_content(self, setup_env):
        home, rcs = setup_env
        original_content = "export PATH=/usr/bin\nalias ll='ls -la'\n"
        (rcs / ".bashrc").write_text("# replacement")
        (home / ".bashrc").write_text(original_content)

        makesymlinks(_make_logger())

        assert (home / ".bashrc.bak").read_text() == original_content


class TestErrorHandling:
    """Test that OS errors are handled gracefully."""

    def test_handles_permission_error_on_symlink(self, setup_env):
        home, rcs = setup_env
        (rcs / ".bashrc").write_text("# bash")
        # Make home directory read-only so symlink creation fails
        home.chmod(0o444)

        # Should not raise — error is logged instead
        makesymlinks(_make_logger())

        # Restore permissions for cleanup
        home.chmod(0o755)

    def test_handles_permission_error_on_rename(self, setup_env, tmp_path):
        home, rcs = setup_env
        (rcs / ".bashrc").write_text("# new")
        (home / ".bashrc").write_text("# old")
        # Make home read-only so rename fails
        home.chmod(0o444)

        # Should not raise
        makesymlinks(_make_logger())

        # Restore permissions for cleanup
        home.chmod(0o755)


class TestEdgeCases:
    """Test edge cases and boundary conditions."""

    def test_empty_rcs_directory(self, setup_env):
        """No files in rcs/ — should complete without error."""
        makesymlinks(_make_logger())

    def test_file_with_spaces_in_name(self, setup_env):
        home, rcs = setup_env
        (rcs / ".my config").write_text("# spaced")

        makesymlinks(_make_logger())

        assert (home / ".my config").is_symlink()


class TestSetupTmux:
    """Test the tmux bootstrap behavior."""

    def test_clones_repo_when_missing(self, tmp_path):
        home = tmp_path / "home"
        home.mkdir()

        with patch.object(mod.subprocess, "run") as mock_run:
            setup_tmux(_make_logger(), str(home))

        mock_run.assert_called_once()
        args = mock_run.call_args
        assert args[0][0] == ['git', 'clone', mod.TMUX_REPO, str(home / '.tmux')]

    def test_skips_clone_when_dir_exists(self, tmp_path):
        home = tmp_path / "home"
        home.mkdir()
        tmux_dir = home / ".tmux"
        tmux_dir.mkdir()
        (tmux_dir / ".tmux.conf").write_text("# upstream")

        with patch.object(mod.subprocess, "run") as mock_run:
            setup_tmux(_make_logger(), str(home))

        mock_run.assert_not_called()

    def test_creates_tmux_conf_symlink(self, tmp_path):
        home = tmp_path / "home"
        home.mkdir()
        tmux_dir = home / ".tmux"
        tmux_dir.mkdir()
        (tmux_dir / ".tmux.conf").write_text("# upstream config")

        with patch.object(mod.subprocess, "run"):
            setup_tmux(_make_logger(), str(home))

        link = home / ".tmux.conf"
        assert link.is_symlink()
        assert os.readlink(str(link)) == str(tmux_dir / ".tmux.conf")

    def test_skips_tmux_conf_if_already_symlink(self, tmp_path):
        home = tmp_path / "home"
        home.mkdir()
        tmux_dir = home / ".tmux"
        tmux_dir.mkdir()
        (tmux_dir / ".tmux.conf").write_text("# upstream")
        # Create an existing symlink pointing elsewhere
        other = tmp_path / "other.conf"
        other.write_text("# other")
        (home / ".tmux.conf").symlink_to(str(other))

        with patch.object(mod.subprocess, "run"):
            setup_tmux(_make_logger(), str(home))

        # Should not overwrite existing symlink
        assert os.readlink(str(home / ".tmux.conf")) == str(other)

    def test_backs_up_existing_tmux_conf(self, tmp_path):
        home = tmp_path / "home"
        home.mkdir()
        tmux_dir = home / ".tmux"
        tmux_dir.mkdir()
        (tmux_dir / ".tmux.conf").write_text("# upstream")
        (home / ".tmux.conf").write_text("# old config")

        with patch.object(mod.subprocess, "run"):
            setup_tmux(_make_logger(), str(home))

        assert (home / ".tmux.conf.bak").read_text() == "# old config"
        assert (home / ".tmux.conf").is_symlink()

    def test_handles_clone_failure(self, tmp_path):
        home = tmp_path / "home"
        home.mkdir()
        import subprocess

        with patch.object(mod.subprocess, "run",
                          side_effect=subprocess.CalledProcessError(1, "git")):
            # Should not raise
            setup_tmux(_make_logger(), str(home))

        # No symlink should be created since clone failed
        assert not (home / ".tmux.conf").exists()

    def test_handles_git_not_found(self, tmp_path):
        home = tmp_path / "home"
        home.mkdir()

        with patch.object(mod.subprocess, "run",
                          side_effect=FileNotFoundError("git not found")):
            # Should not raise
            setup_tmux(_make_logger(), str(home))

        assert not (home / ".tmux.conf").exists()
