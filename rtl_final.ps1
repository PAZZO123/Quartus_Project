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

public class SeqRTL {
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

Get-Process | Where-Object { $_.Name -like "*chrome*" -and $_.MainWindowHandle -ne [IntPtr]::Zero } | ForEach-Object { [SeqRTL]::MinimizeWnd($_.MainWindowHandle) }
Start-Sleep -Milliseconds 400

$proc = Get-Process -Id 49136
[SeqRTL]::ForceFront($proc.MainWindowHandle)
Start-Sleep -Milliseconds 500

$log = @("Focus: $([SeqRTL]::IsFg($proc.MainWindowHandle))")

if ([SeqRTL]::IsFg($proc.MainWindowHandle)) {
    # Redo the sequence: Alt+T + 7 Down + Right + screenshot submenu + Enter
    [SeqRTL]::SendAltT()
    Start-Sleep -Milliseconds 900
    
    for ($i = 0; $i -lt 7; $i++) { [SeqRTL]::TypeKey(0x28) }  # 7x Down
    Start-Sleep -Milliseconds 400
    
    # Open submenu with Right arrow
    [SeqRTL]::TypeKey(0x27)  # VK_RIGHT
    Start-Sleep -Milliseconds 700
    
    # Screenshot of submenu
    [int]$w=1920; [int]$h=1080
    $b = New-Object System.Drawing.Bitmap($w,$h)
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g.Dispose()
    $b.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_rtl_sub.png")
    $b.Dispose()
    
    $log += "Submenu screenshot taken"
    
    # Press Enter to open RTL Viewer (first item should be selected)
    [SeqRTL]::TypeKey(0x0D)  # VK_RETURN
    Start-Sleep -Milliseconds 5000  # Wait for RTL viewer to load
    
    # Take screenshot of RTL viewer
    $b2 = New-Object System.Drawing.Bitmap($w,$h)
    $g2 = [System.Drawing.Graphics]::FromImage($b2)
    $g2.CopyFromScreen(0,0,0,0,(New-Object System.Drawing.Size($w,$h)))
    $g2.Dispose()
    $b2.Save("C:\Users\USER\Documents\MIPS_Project\screenshots\screen_rtl_viewer.png")
    $b2.Dispose()
    
    $log += "RTL viewer screenshot taken"
}

$log | Out-File "C:\Users\USER\Documents\MIPS_Project\seq_log.txt" -Force
