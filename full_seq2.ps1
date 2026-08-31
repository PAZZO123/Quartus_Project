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

public class SeqFull {
    [DllImport("user32.dll")] public static extern uint SendInput(uint n, INPUT[] p, int cb);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, int e);
    [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte sc, uint f, int ex);
    
    public static void MinimizeWindow(IntPtr h) { ShowWindow(h, 6); Thread.Sleep(200); }
    
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
    
    public static void SendAltT() {
        INPUT[] inp = new INPUT[4];
        inp[0].type=1; inp[0].u.ki.wVk=0x12;
        inp[1].type=1; inp[1].u.ki.wVk=0x54;
        inp[2].type=1; inp[2].u.ki.wVk=0x54; inp[2].u.ki.dwFlags=2;
        inp[3].type=1; inp[3].u.ki.wVk=0x12; inp[3].u.ki.dwFlags=2;
        SendInput(4, inp, System.Runtime.InteropServices.Marshal.SizeOf(typeof(INPUT)));
    }
    public static void Move(int x, int y) { SetCursorPos(x, y); Thread.Sleep(60); }
    public static void Click(int x, int y) {
        SetCursorPos(x, y); Thread.Sleep(120);
        mouse_event(2, (uint)x, (uint)y, 0, 0); Thread.Sleep(80);
        mouse_event(4, (uint)x, (uint)y, 0, 0);
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Step 1: Minimize all Chrome windows to remove foreground competition
$chromes = Get-Process | Where-Object { $_.Name -like "*chrome*" -and $_.MainWindowHandle -ne [IntPtr]::Zero }
foreach ($c in $chromes) {
    [SeqFull]::MinimizeWindow($c.MainWindowHandle)
}
Start-Sleep -Milliseconds 500

# Step 2: Now force Quartus ALU to front
$proc = Get-Process -Id 49136
[SeqFull]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 600

$fg = [SeqFull]::IsFg($proc.MainWindowHandle)
"After Chrome minimize, focus: $fg" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt"

if ($fg) {
    # Step 3: Send Alt+T
    [SeqFull]::SendAltT()
    Start-Sleep -Milliseconds 900
    
    # Save screenshot 1 (Tools menu)
    [int]$w=1920; [int]$h=1080
    $b = New-Object System.Drawing.Bitmap($w,$h)
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g.Dispose()
    $b.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_seq1b.png"); $b.Dispose()
    
    # Step 4: Move to Netlist Viewers
    [SeqFull]::Move(320, 181)
    Start-Sleep -Milliseconds 700
    
    # Save screenshot 2 (submenu)
    $b2 = New-Object System.Drawing.Bitmap($w,$h)
    $g2 = [System.Drawing.Graphics]::FromImage($b2)
    $g2.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g2.Dispose()
    $b2.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_seq2b.png"); $b2.Dispose()
    
    "Sequence done" | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt" -Append
}
