import os
import sys
import subprocess

def run_command(cmd):
    """Executes shell command and returns output."""
    try:
        result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
        return result.stdout if result.returncode == 0 else result.stderr
    except Exception as e:
        return str(e)

def main():
    print("--- NexaForge AI Agent Runner Initialized ---")
    status = run_command("git status -s")
    print(f"Current Workspace Status:\n{status if status else 'Clean workspace'}")

if __name__ == "__main__":
    main()
