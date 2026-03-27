#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

// app_links: Hỗ trợ single-instance để chuyển deep link tới app đang chạy
#include <app_links/app_links_plugin_c_api.h>

// Tên cửa sổ app (phải khớp với title trong window.Create bên dưới)
constexpr const wchar_t kAppTitle[] = L"app_fe_ecomerce";
// Mutex name để kiểm tra single instance
constexpr const wchar_t kMutexName[] = L"app_fe_ecomerce_single_instance_mutex";

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // === SINGLE INSTANCE CHECK ===
  // Tạo Named Mutex. Nếu đã tồn tại → app đang chạy → gửi deep link sang instance cũ
  HANDLE mutex = ::CreateMutex(NULL, TRUE, kMutexName);
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    // Tìm cửa sổ app đang chạy
    HWND existingWindow = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", kAppTitle);
    if (existingWindow) {
      // Gửi deep link URL (từ command line args) qua WM_COPYDATA tới instance cũ
      SendAppLink(existingWindow);

      // Đưa cửa sổ cũ lên foreground
      ::ShowWindow(existingWindow, SW_RESTORE);
      ::SetForegroundWindow(existingWindow);
    }
    // Đóng instance mới, không mở cửa sổ thứ 2
    ::CloseHandle(mutex);
    return EXIT_SUCCESS;
  }

  // === NORMAL STARTUP (instance đầu tiên) ===
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(kAppTitle, origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // Giải phóng mutex khi app đóng
  ::ReleaseMutex(mutex);
  ::CloseHandle(mutex);

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
