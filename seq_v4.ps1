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

public class SeqV4 {
    [DllImport("user32.dll")] public static extern uint SendInput(uint n, INPUT[] p, int cb);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    
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
    
    public static void SendKey(ushort vk, bool keyup) {
        INPUT[] inp = new INPUT[1];
        inp[0].type = 1;
        inp[0].u.ki.wVk = vk;
        inp[0].u.ki.dwFlags = keyup ? (uint)2 : (uint)0;
        SendInput(1, inp, System.Runtime.InteropServices.Marshal.SizeOf(typeof(INPUT)));
    }
    
    public static void TypeKey(ushort vk) {
        SendKey(vk, false); Thread.Sleep(80); SendKey(vk, true); Thread.Sleep(80);
    }
    
    public static void SendAltT() {
        INPUT[] inp = new INPUT[4];
        inp[0].type=1; inp[0].u.ki.wVk=0x12;
        inp[1].type=1; inp[1].u.ki.wVk=0x54;
        inp[2].type=1; inp[2].u.ki.wVk=0x54; inp[2].u.ki.dwFlags=2;
        inp[3].type=1; inp[3].u.ki.wVk=0x12; inp[3].u.ki.dwFlags=2;
        SendInput(4, inp, System.Runtime.InteropServices.Marshal.SizeOf(typeof(INPUT)));
    }
    
    public static void MinimizeWnd(IntPtr h) { ShowWindow(h, 6); Thread.Sleep(150); }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Minimize Chrome
$chromes = Get-Process | Where-Object { $_.Name -like "*chrome*" -and $_.MainWindowHandle -ne [IntPtr]::Zero }
foreach ($c in $chromes) { [SeqV4]::MinimizeWnd($c.MainWindowHandle) }
Start-Sleep -Milliseconds 500

# Focus ALU Quartus
$proc = Get-Process -Id 49136
[SeqV4]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 600

if ([SeqV4]::IsFg($proc.MainWindowHandle)) {
    # 1. Alt+T to open Tools menu
    [SeqV4]::SendAltT()
    Start-Sleep -Milliseconds 800
    
    # 2. Press 'N' to jump to Netlist Viewers
    [SeqV4]::TypeKey(0x4E)  # 'N' key
    Start-Sleep -Milliseconds 600
    
    # Screenshot: Netlist Viewers should be highlighted
    [int]$w=1920; [int]$h=1080
    $b = New-Object System.Drawing.Bitmap($w,$h)
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g.Dispose()
    $b.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_N_key.png")
    $b.Dispose()
    
    # 3. Press right-arrow to open Netlist Viewers submenu
    [SeqV4]::TypeKey(0x27)  # Right arrow
    Start-Sleep -Milliseconds 700
    
    # Screenshot: RTL Viewer submenu should be visible
    $b2 = New-Object System.Drawing.Bitmap($w,$h)
    $g2 = [System.Drawing.Graphics]::FromImage($b2)
    $g2.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g2.Dispose()
    $b2.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_netlist_submenu.png")
    $b2.Dispose()
    
    "Sequence complete" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt"
} else {
    "Focus failed" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt"
}
