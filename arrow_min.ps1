Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public struct INPUT { public uint type; public INPUTUNION u; }
[StructLayout(LayoutKind.Explicit)]
public struct INPUTUNION {
    [FieldOffset(0)] public MOUSEINPUT mi;
    [FieldOffset(0)] public KEYBDINPUT ki;
}
public struct MOUSEINPUT { public int dx,dy,mouseData,dwFlags,time; public IntPtr dwExtraInfo; }
public struct KEYBDINPUT { public ushort wVk,wScan; public uint dwFlags,time; public IntPtr dwExtraInfo; }

public class SeqMin {
    [DllImport("user32.dll")] public static extern uint SendInput(uint n, INPUT[] p, int cb);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    public static void MinimizeWnd(IntPtr h) { ShowWindow(h, 6); Thread.Sleep(100); }
    public static void ForceFront(IntPtr hWnd) {
        IntPtr fg = GetForegroundWindow();
        uint pid; uint fgT = GetWindowThreadProcessId(fg, out pid);
        uint myT = GetCurrentThreadId();
        AttachThreadInput(myT, fgT, true);
        BringWindowToTop(hWnd); ShowWindow(hWnd, 3); SetForegroundWindow(hWnd);
        Thread.Sleep(200);
        AttachThreadInput(myT, fgT, false);
    }
    public static bool IsFg(IntPtr h) { return GetForegroundWindow() == h; }
    public static void TypeKey(ushort vk) {
        INPUT[] inp = new INPUT[2];
        inp[0].type=1; inp[0].u.ki.wVk=vk;
        inp[1].type=1; inp[1].u.ki.wVk=vk; inp[1].u.ki.dwFlags=2;
        SendInput(2, inp, System.Runtime.InteropServices.Marshal.SizeOf(typeof(INPUT)));
        Thread.Sleep(120);
    }
    public static void SendAltT() {
        INPUT[] inp = new INPUT[4];
        inp[0].type=1; inp[0].u.ki.wVk=0x12;
        inp[1].type=1; inp[1].u.ki.wVk=0x54;
        inp[2].type=1; inp[2].u.ki.wVk=0x54; inp[2].u.ki.dwFlags=2;
        inp[3].type=1; inp[3].u.ki.wVk=0x12; inp[3].u.ki.dwFlags=2;
        SendInput(4, inp, System.Runtime.InteropServices.Marshal.SizeOf(typeof(INPUT)));
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$log = @()

# Minimize Chrome
Get-Process | Where-Object { $_.Name -like "*chrome*" -and $_.MainWindowHandle -ne [IntPtr]::Zero } | ForEach-Object { [SeqMin]::MinimizeWnd($_.MainWindowHandle) }
Start-Sleep -Milliseconds 400

$proc = Get-Process -Id 49136
[SeqMin]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 500

$isFg = [SeqMin]::IsFg($proc.MainWindowHandle)
$log += "Focus: $isFg"

if ($isFg) {
    # Open Tools menu
    [SeqMin]::SendAltT()
    Start-Sleep -Milliseconds 900
    
    # 7 Down arrows to reach Netlist Viewers
    for ($i = 0; $i -lt 7; $i++) {
        [SeqMin]::TypeKey(0x28)  # VK_DOWN
    }
    Start-Sleep -Milliseconds 500
    
    # Screenshot of menu state
    [int]$w=1920; [int]$h=1080
    $b = New-Object System.Drawing.Bitmap($w,$h)
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g.Dispose()
    $b.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_7down_min.png")
    $b.Dispose()
    
    $log += "7 downs done"
}

$log | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt" -Force
