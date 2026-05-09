Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Threading;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;

public class RTLCapture {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint id);
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
    [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr h);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc p, IntPtr lp);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder sb, int max);
    [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, IntPtr e);
    
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lp);
    
    public static IntPtr FindWindow(string prefix) {
        IntPtr found = IntPtr.Zero;
        EnumWindows((h, p) => {
            var sb = new StringBuilder(512);
            GetWindowText(h, sb, 512);
            if (sb.ToString().StartsWith(prefix)) { found = h; return false; }
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static void Run() {
        IntPtr rtl = FindWindow("RTL Viewer");
        string status = "RTL not found";
        if (rtl != IntPtr.Zero) {
            // Minimize other apps
            foreach (var p in System.Diagnostics.Process.GetProcesses()) {
                try {
                    string n = p.ProcessName.ToLower();
                    if ((n.Contains("chrome") || n.Contains("edge") || n.Contains("winword") || n.Contains("quartus"))
                        && p.MainWindowHandle != IntPtr.Zero && p.MainWindowHandle != rtl)
                        ShowWindow(p.MainWindowHandle, 6);
                } catch {}
            }
            Thread.Sleep(400);
            ShowWindow(rtl, 3); // maximize
            Thread.Sleep(500);
            IntPtr fg = GetForegroundWindow();
            uint dummy;
            uint fgTid = GetWindowThreadProcessId(fg, out dummy);
            uint myTid = GetCurrentThreadId();
            AttachThreadInput(myTid, fgTid, true);
            BringWindowToTop(rtl);
            SetForegroundWindow(rtl);
            AttachThreadInput(myTid, fgTid, false);
            Thread.Sleep(800);
            // Press Ctrl+W to fit width or just wait
            Thread.Sleep(200);
            var s = Screen.PrimaryScreen.Bounds;
            var bmp = new Bitmap(s.Width, s.Height);
            var g = Graphics.FromImage(bmp);
            g.CopyFromScreen(s.Location, Point.Empty, s.Size);
            bmp.Save("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\screen_rtl_fa_clean.png", ImageFormat.Png);
            g.Dispose(); bmp.Dispose();
            status = "captured:" + rtl.ToString();
        }
        System.IO.File.WriteAllText("C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots\\rtl_clean_status.txt", status);
    }
}
"@ -ReferencedAssemblies System.Drawing, System.Windows.Forms

[RTLCapture]::Run()
