# ============================================================
# Run all 4 ModelSim simulations and capture real wave screenshots
# Strategy: DO script writes sim_done.txt marker when wave is ready,
#           launcher finds ModelSim window by PID and captures it.
# ============================================================
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$VSIM   = "C:\altera\13.1\modelsim_ase\win32aloem\vsim.exe"
$PROJ   = "C:\Users\USER\Documents\MIPS_Project"
$DO_DIR = "$PROJ\sim_do"
$SHOTS  = "$PROJ\screenshots"

# Win32 API for window capture by PID
Add-Type `
  -ReferencedAssemblies "System.Drawing.dll" `
  -TypeDefinition @"
using System;
using System.Drawing;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public class Win32Cap {
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] static extern bool PrintWindow(IntPtr h, IntPtr dc, uint flags);
    [DllImport("user32.dll")] static extern bool SetWindowPos(IntPtr h, IntPtr ins, int x, int y, int cx, int cy, uint f);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumWinProc cb, IntPtr lp);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] static extern int GetWindowText(IntPtr h, StringBuilder s, int max);
    public delegate bool EnumWinProc(IntPtr h, IntPtr lp);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L,T,R,B; }

    public static IntPtr FindLargestWindowByPid(int pid) {
        IntPtr best = IntPtr.Zero;
        int bestArea = 0;
        EnumWindows(delegate(IntPtr h, IntPtr lp) {
            uint wpid;
            GetWindowThreadProcessId(h, out wpid);
            if ((int)wpid == pid && IsWindowVisible(h)) {
                RECT r; GetWindowRect(h, out r);
                int area = (r.R - r.L) * (r.B - r.T);
                if (area > bestArea) { bestArea = area; best = h; }
            }
            return true;
        }, IntPtr.Zero);
        return best;
    }

    public static Bitmap Capture(IntPtr h) {
        RECT r; GetWindowRect(h, out r);
        int w = r.R - r.L; int hh = r.B - r.T;
        if (w < 1 || hh < 1) return null;
        // Make topmost so PrintWindow can render it
        SetWindowPos(h, new IntPtr(-1), 0, 0, 0, 0, 0x0003);
        System.Threading.Thread.Sleep(600);
        Bitmap bmp = new Bitmap(w, hh);
        Graphics g = Graphics.FromImage(bmp);
        IntPtr dc = g.GetHdc();
        bool ok = PrintWindow(h, dc, 0x00000002);
        g.ReleaseHdc(dc); g.Dispose();
        return ok ? bmp : null;
    }
}
"@

function Run-Sim {
    param(
        [string]$Label,
        [string]$DoFile,
        [string]$OutPng,
        [string]$WorkDir
    )
    Write-Host ""
    Write-Host "========================================"
    Write-Host " $Label"
    Write-Host "========================================"

    # Clean work dir
    if (Test-Path $WorkDir) {
        Get-Process -Name "vsim" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
        Start-Sleep 2
        Remove-Item $WorkDir -Recurse -Force -EA SilentlyContinue
    }
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

    $markerFile = "$WorkDir\sim_done.txt"
    $doneFile   = Join-Path $WorkDir "sim_done.txt"

    # Launch ModelSim GUI
    $proc = Start-Process -FilePath $VSIM `
        -ArgumentList "-do `"$DoFile`"" `
        -WorkingDirectory $WorkDir `
        -PassThru
    Write-Host "  Launched PID $($proc.Id)"

    # Wait up to 120s for marker file
    $t = 0
    while (-not (Test-Path $doneFile) -and $t -lt 120) {
        Start-Sleep 2; $t += 2
        Write-Host "  ... $t s"
    }

    if (-not (Test-Path $doneFile)) {
        Write-Host "  ERROR: sim_done.txt never appeared"
        Stop-Process -Id $proc.Id -Force -EA SilentlyContinue
        return
    }

    Write-Host "  Wave ready! Capturing..."
    Start-Sleep 2  # extra settle time

    $hwnd = [Win32Cap]::FindLargestWindowByPid($proc.Id)
    Write-Host "  HWND: $hwnd"

    if ($hwnd -ne [IntPtr]::Zero) {
        $bmp = [Win32Cap]::Capture($hwnd)
        if ($bmp) {
            $bmp.Save($OutPng)
            Write-Host "  Saved: $OutPng  ($($bmp.Width) x $($bmp.Height))"
            $bmp.Dispose()
        } else {
            Write-Host "  WARNING: PrintWindow returned null"
        }
    } else {
        Write-Host "  WARNING: No window found for PID $($proc.Id)"
    }

    # ModelSim will quit itself after 20s delay in DO script
    Write-Host "  Waiting for ModelSim to exit..."
    $proc.WaitForExit(30000) | Out-Null
    Get-Process -Name "vsim" -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
    Start-Sleep 3
}

Run-Sim -Label "Part 1a: Full Adder 32-bit" `
    -DoFile "$DO_DIR\sim_fa.do"   -OutPng "$SHOTS\wave_fa.png"   -WorkDir "$PROJ\sim_fa_run"

Run-Sim -Label "Part 1b: 4-to-1 MUX 32-bit" `
    -DoFile "$DO_DIR\sim_mux.do"  -OutPng "$SHOTS\wave_mux.png"  -WorkDir "$PROJ\sim_mux_run"

Run-Sim -Label "Part 1c: ALU 32-bit" `
    -DoFile "$DO_DIR\sim_alu.do"  -OutPng "$SHOTS\wave_alu.png"  -WorkDir "$PROJ\sim_alu_run"

Run-Sim -Label "Part 2:  MIPS Processor" `
    -DoFile "$DO_DIR\sim_mips.do" -OutPng "$SHOTS\wave_mips.png" -WorkDir "$PROJ\sim_mips_run"

Write-Host ""
Write-Host "========================================"
Write-Host " ALL DONE"
Get-ChildItem "$SHOTS\wave_*.png" -EA SilentlyContinue | Select-Object Name, Length | Format-Table
Write-Host "========================================"
