// Cho phép Firefox nạp chrome/userChrome.css và chrome/userContent.css.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("browser.theme.content-theme", 0);
// Tránh Firefox tách tab thành cửa sổ mới khi thao tác chuột bị rê nhẹ.
user_pref("browser.tabs.allowTabDetach", false);
