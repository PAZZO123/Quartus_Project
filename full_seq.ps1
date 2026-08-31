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

public class FullSeq {
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
    
    public static void ForceFront(IntPtr hWnd) {
        IntPtr fg = GetForegroundWindow();
        uint pid; uint fgT = GetWindowThreadProcessId(fg, out pid);
        uint myT = GetCurrentThreadId();
        AttachThreadInput(myT, fgT, true);
        BringWindowToTop(hWnd); ShowWindow(hWnd, 3); SetForegroundWindow(hWnd);
        Thread.Sleep(100);
        AttachThreadInput(myT, fgT, false);
    }
    public static bool IsFg(IntPtr h) { return GetForegroundWindow() == h; }
    
    public static void SendAltT() {
        INPUT[] inp = new INPUT[4];
        inp[0].type=1; inp[0].u.ki.wVk=0x12; inp[0].u.ki.dwFlags=0;      // Alt down
        inp[1].type=1; inp[1].u.ki.wVk=0x54; inp[1].u.ki.dwFlags=0;      // T down
        inp[2].type=1; inp[2].u.ki.wVk=0x54; inp[2].u.ki.dwFlags=2;      // T up
        inp[3].type=1; inp[3].u.ki.wVk=0x12; inp[3].u.ki.dwFlags=2;      // Alt up
        SendInput(4, inp, System.Runtime.InteropServices.Marshal.SizeOf(typeof(INPUT)));
    }
    public static void Move(int x, int y) { SetCursorPos(x, y); Thread.Sleep(50); }
    public static void Click(int x, int y) {
        SetCursorPos(x, y); Thread.Sleep(120);
        mouse_event(2, (uint)x, (uint)y, 0, 0); Thread.Sleep(80);
        mouse_event(4, (uint)x, (uint)y, 0, 0);
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$proc = Get-Process -Id 49136
[FullSeq]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 600

$log = "Focus: $([FullSeq]::IsFg($proc.MainWindowHandle))"

if ([FullSeq]::IsFg($proc.MainWindowHandle)) {
    # Step 1: Open Tools menu
    [FullSeq]::SendAltT()
    Start-Sleep -Milliseconds 900
    
    # Screenshot 1: Tools menu open
    [int]$w = 1920; [int]$h = 1080
    $b1 = New-Object System.Drawing.Bitmap($w, $h)
    $g1 = [System.Drawing.Graphics]::FromImage($b1)
    $g1.CopyFromScreen(0, 0, 0, 0, (New-Object System.Drawing.Size($w, $h)))
    $g1.Dispose()
    $b1.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_seq1_tools.png")
    $b1.Dispose()
    
    # Step 2: Move to Netlist Viewers (x=320, y=181)
    [FullSeq]::Move(320, 181)
    Start-Sleep -Milliseconds 800
    
    # Screenshot 2: Netlist Viewers submenu open
    $b2 = New-Object System.Drawing.Bitmap($w, $h)
    $g2 = [System.Drawing.Graphics]::FromImage($b2)
    $g2.CopyFromScreen(0, 0, 0, 0, (New-Object System.Drawing.Size($w, $h)))
    $g2.Dispose()
    $b2.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_seq2_netlist.png")
    $b2.Dispose()
    
    $log += " | Seq complete"
} else {
    $log += " | Focus failed"
}

$log | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt"
