import os
import sys
import time
import subprocess
import requests

API_KEY = os.getenv("GEMINI_API_KEY")
MODEL = "gemini-3.6-flash"
MAIN_DART_PATH = "app/lib/main.dart"

def run_command(cmd, cwd=None):
    res = subprocess.run(cmd, shell=True, text=True, capture_output=True, cwd=cwd)
    return res.returncode, res.stdout, res.stderr

def validate_dart():
    print("[*] Local Dart syntax verify kar raha hai...")
    code, out, err = run_command("dart format --output=none lib/main.dart", cwd="app")
    if code == 0:
        print("[+] Syntax valid hai!")
        return True, ""
    else:
        error_msg = err if err else out
        print("[-] Syntax error mila:")
        print(error_msg.strip())
        return False, error_msg

def call_gemini(system_prompt, user_prompt):
    if not API_KEY:
        print("[-] Error: GEMINI_API_KEY set nahi hai.")
        sys.exit(1)

    api_url = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={API_KEY}"
    headers = {"Content-Type": "application/json"}
    payload = {
        "systemInstruction": {"parts": [{"text": system_prompt}]},
        "contents": [{"parts": [{"text": user_prompt}]}]
    }

    print(f"[*] Calling Gemini REST API ({MODEL})...")
    try:
        response = requests.post(api_url, headers=headers, json=payload, timeout=90)
        if response.status_code == 200:
            return response.json()['candidates'][0]['content']['parts'][0]['text']
        else:
            print(f"[-] API Error ({response.status_code}): {response.text}")
            return None
    except Exception as e:
        print(f"[-] Network Exception: {e}")
        return None

def apply_patch(original_code, patch_text):
    updated_code = original_code
    blocks = patch_text.split("<<<<<<< SEARCH")
    if len(blocks) <= 1:
        print("[-] Koi SEARCH/REPLACE block detect nahi hua.")
        return None

    for block in blocks[1:]:
        if "=======" not in block or ">>>>>>> REPLACE" not in block:
            continue
        parts = block.split("=======")
        search_part = parts[0].strip("\r\n")
        replace_part = parts[1].split(">>>>>>> REPLACE")[0].strip("\r\n")
        
        if search_part in updated_code:
            updated_code = updated_code.replace(search_part, replace_part, 1)
        else:
            print(f"[!] Search target match nahi hua:\n{search_part[:60]}...")
            return None
    return updated_code

def apply_task(instruction):
    print(f"\n[+] Task shuru: '{instruction}'")
    with open(MAIN_DART_PATH, "r") as f:
        original_code = f.read()

    # Dashboard section target karne ke liye lines filter karte hain
    lines = original_code.splitlines()
    sample_context = "\n".join(lines[:120]) + "\n...\n" + "\n".join(lines[1600:1750])

    system_prompt = (
        "You are an expert Flutter engineer inside NexaForgeOS. "
        "Strictly output only SEARCH/REPLACE blocks. No markdown formatting backticks around the blocks. "
        "Format:\n"
        "<<<<<<< SEARCH\n"
        "exact lines from file\n"
        "=======\n"
        "replacement lines\n"
        ">>>>>>> REPLACE\n\n"
        "Rules:\n"
        "1. Never leave unescaped '$' characters in string literals (use '\\$').\n"
        "2. Ensure all curly braces and parentheses match perfectly.\n"
        "3. Keep search targets short and unique."
    )
    
    prompt = f"Task: {instruction}\n\nContext excerpt:\n{sample_context}"

    for attempt in range(1, 3):
        patch_text = call_gemini(system_prompt, prompt)
        if not patch_text:
            print("[-] Patch nahi mila. Abort.")
            return

        new_code = apply_patch(original_code, patch_text)
        if not new_code:
            print(f"[-] Patch application failed (Attempt {attempt}).")
            prompt = f"Previous patch failed to match text. Please provide accurate SEARCH lines from this context:\n{sample_context}"
            continue

        with open(MAIN_DART_PATH, "w") as f:
            f.write(new_code)

        valid, error = validate_dart()
        if valid:
            print("[+] Code modify aur verify ho gaya!")
            run_command(f"git add {MAIN_DART_PATH} agent/runner.py")
            commit_msg = f"feat(ui): {instruction}"
            run_command(f'git commit -m "{commit_msg}"')
            print("[*] GitHub par push ho raha hai...")
            code, out, err = run_command("git push origin master")
            if code == 0:
                print("[+] Successfully pushed to GitHub! Cloud build trigger ho chuki hai.")
            else:
                print(f"[-] Push failed: {err if err else out}")
            return
        else:
            print(f"[-] Syntax test fail hua. Self-healing attempt {attempt}...")
            prompt = f"The code produced this dart format error:\n{error}\nFix it and provide the correct SEARCH/REPLACE block."

    print("[-] Reverting original file...")
    with open(MAIN_DART_PATH, "w") as f:
        f.write(original_code)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python agent/runner.py \"Your task description here\"")
    else:
        apply_task(" ".join(sys.argv[1:]))
