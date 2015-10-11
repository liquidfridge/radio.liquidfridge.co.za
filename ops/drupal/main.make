core = 7.x
api = 2



; Core
projects[drupal][version] = "7.39"
projects[drupal][patch][2400287] = "https://raw.github.com/netbek/drupal-patches/7.x/core/drupal-remove_js_source_maps.patch"



; Modules
projects[admin_menu][type] = "module"
projects[admin_menu][version] = "3.0-rc5"

projects[adminimal_admin_menu][type] = "module"
projects[adminimal_admin_menu][version] = "1.6"
projects[adminimal_admin_menu][patch][2407007] = "https://www.drupal.org/files/issues/adminimal_admin_menu-js-error-2407007-3-no-whitespace-changes.patch"

projects[better_formats][type] = "module"
projects[better_formats][version] = "1.x"
projects[better_formats][download][type] = "git"
projects[better_formats][download][revision] = "3b4a8c9"
projects[better_formats][download][branch] = "7.x-1.x"

projects[boost][type] = "module"
projects[boost][version] = "1.x"
projects[boost][download][type] = "git"
projects[boost][download][revision] = "b864ee7"
projects[boost][download][branch] = "7.x-1.x"
projects[boost][patch][1176534] = "https://www.drupal.org/files/no_white_page_if_redirect-1176534-3.patch"
projects[boost][patch][1957532] = "https://www.drupal.org/files/issues/boost_redirect-1957532-11.patch"

projects[breakpoints][type] = "module"
projects[breakpoints][version] = "1.3"

projects[calypso][type] = "module"
projects[calypso][download][type] = "git"
projects[calypso][download][branch] = "7.x-1.x"
projects[calypso][download][url] = "https://github.com/liquidfridge/calypso.git"

projects[calypso_features][type] = "module"
projects[calypso_features][download][type] = "git"
projects[calypso_features][download][branch] = "7.x-1.x"
projects[calypso_features][download][url] = "https://github.com/liquidfridge/calypso_features.git"

; projects[caption_filter][type] = "module"
; projects[caption_filter][download][type] = "git"
; projects[caption_filter][download][revision] = "d799f69"
; projects[caption_filter][download][branch] = "7.x-1.x"
; projects[caption_filter][patch][696734] = "https://www.drupal.org/files/issues/ckeditor_alignment_integration_696734-50.patch"
; projects[caption_filter][patch][2300273] = "https://www.drupal.org/files/issues/caption-filter-2300273-1-single-quote.patch"

projects[ckeditor][type] = "module"
projects[ckeditor][version] = "1.x"
projects[ckeditor][download][type] = "git"
projects[ckeditor][download][revision] = "32f0973"
projects[ckeditor][download][branch] = "7.x-1.x"
projects[ckeditor][patch][] = "https://raw.github.com/netbek/drupal-patches/7.x/contrib/ckeditor/ckeditor-instance-config.patch"
projects[ckeditor][patch][2542566] = "https://www.drupal.org/files/issues/ckeditor-remove_media_integration-2542566-5.patch"

; projects[ckeditor_image2][type] = "module"
; projects[ckeditor_image2][download][type] = "git"
; projects[ckeditor_image2][download][revision] = "6d71e6d"
; projects[ckeditor_image2][download][branch] = "7.x-1.x"
; projects[ckeditor_image2][download][url] = "http://git.drupal.org/sandbox/jwilson3/2454995.git"

projects[ckeditor_link][type] = "module"
projects[ckeditor_link][version] = "2.x"
projects[ckeditor_link][download][type] = "git"
projects[ckeditor_link][download][revision] = "de4a8b8"
projects[ckeditor_link][download][branch] = "7.x-2.x"

projects[conflict][type] = "module"
projects[conflict][version] = "1.0"

; projects[content_access][type] = "module"
; projects[content_access][version] = "1.2-beta2"

projects[ctools][type] = "module"
projects[ctools][version] = "1.9"

projects[date][type] = "module"
projects[date][version] = "2.9"

projects[devel][type] = "module"
projects[devel][version] = "1.5"

projects[devel_themer][type] = "module"
projects[devel_themer][version] = "1.x"
projects[devel_themer][download][type] = "git"
projects[devel_themer][download][revision] = "cf347e1"
projects[devel_themer][download][branch] = "7.x-1.x"

; projects[diff][type] = "module"
; projects[diff][version] = "3.2"

projects[elements][type] = "module"
projects[elements][version] = "1.4"

projects[entity][type] = "module"
projects[entity][version] = "1.6"

projects[entityreference][type] = "module"
projects[entityreference][version] = "1.x"
projects[entityreference][download][type] = "git"
projects[entityreference][download][revision] = "ab62b9a"
projects[entityreference][download][branch] = "7.x-1.x"

projects[expire][type] = "module"
projects[expire][version] = "2.0-rc4"

projects[features][type] = "module"
projects[features][version] = "2.6"

projects[features_extra][type] = "module"
projects[features_extra][version] = "1.x"
projects[features_extra][download][type] = "git"
projects[features_extra][download][revision] = "dcf9ad9"
projects[features_extra][download][branch] = "7.x-1.x"

projects[file_entity][type] = "module"
projects[file_entity][version] = "2.0-beta2"

projects[footer_message][type] = "module"
projects[footer_message][version] = "1.1"

; projects[footnotes][type] = "module"
; projects[footnotes][version] = "2.x"
; projects[footnotes][download][type] = "git"
; projects[footnotes][download][revision] = "7b12c77"
; projects[footnotes][download][branch] = "7.x-2.x"
; projects[footnotes][patch][1589130] = "https://www.drupal.org/files/footnotes-wysiwyg_fix_js_error_ckeditor-1589130-6.patch"

projects[honeypot][type] = "module"
projects[honeypot][version] = "1.21"

projects[httprl][type] = "module"
projects[httprl][version] = "1.14"

; projects[icomoon][type] = "module"
; projects[icomoon][version] = "1.0"

; projects[icon][type] = "module"
; projects[icon][version] = "1.0-beta6"

projects[ife][type] = "module"
projects[ife][version] = "2.x"
projects[ife][download][type] = "git"
projects[ife][download][revision] = "f43c621"
projects[ife][download][branch] = "7.x-2.x"

projects[jquery_update][type] = "module"
projects[jquery_update][version] = "3.0-alpha2"

projects[libraries][type] = "module"
projects[libraries][version] = "2.2"

projects[logging_alerts][type] = "module"
projects[logging_alerts][version] = "2.2"

projects[login_redirect][type] = "module"
projects[login_redirect][version] = "1.2"
projects[login_redirect][patch][2401613] = "https://www.drupal.org/files/issues/change_module_setting_link-2401613-1.patch"

projects[login_security][type] = "module"
projects[login_security][version] = "1.x"
projects[login_security][download][type] = "git"
projects[login_security][download][revision] = "bb4ec66"
projects[login_security][download][branch] = "7.x-1.x"

projects[media][type] = "module"
projects[media][version] = "2.x"
projects[media][download][type] = "git"
projects[media][download][revision] = "cba92a0"
projects[media][download][branch] = "7.x-2.x"
projects[media][patch][951004] = "https://www.drupal.org/files/issues/allow_selecting_of-951004-136.patch"

projects[media_ckeditor][type] = "module"
projects[media_ckeditor][version] = "2.x"
projects[media_ckeditor][download][type] = "git"
projects[media_ckeditor][download][revision] = "7409f2c"
projects[media_ckeditor][download][branch] = "7.x-2.x"

projects[menu_attributes][type] = "module"
projects[menu_attributes][version] = "1.0-rc3"

projects[menu_block][type] = "module"
projects[menu_block][version] = "2.7"

projects[metatag][type] = "module"
projects[metatag][version] = "1.7"

projects[multiform][type] = "module"
projects[multiform][version] = "1.1"

projects[panels][type] = "module"
projects[panels][version] = "3.5"

projects[paranoia][type] = "module"
projects[paranoia][version] = "1.5"

projects[pathauto][type] = "module"
projects[pathauto][version] = "1.x"
projects[pathauto][download][type] = "git"
projects[pathauto][download][revision] = "110be4c"
projects[pathauto][download][branch] = "7.x-1.x"

projects[pathologic][type] = "module"
projects[pathologic][version] = "3.x"
projects[pathologic][download][type] = "git"
projects[pathologic][download][revision] = "d734fda"
projects[pathologic][download][branch] = "7.x-3.x"

projects[picture][type] = "module"
projects[picture][version] = "2.12"

projects[plupload][type] = "module"
projects[plupload][version] = "1.7"

projects[redirect][type] = "module"
projects[redirect][version] = "1.0-rc3"

projects[responsive_menus][type] = "module"
projects[responsive_menus][version] = "1.x"
projects[responsive_menus][download][type] = "git"
projects[responsive_menus][download][revision] = "1d829b1"
projects[responsive_menus][download][branch] = "7.x-1.x"

projects[security_review][type] = "module"
projects[security_review][version] = "1.2"

projects[simplehtmldom][type] = "module"
projects[simplehtmldom][version] = "1.12"

projects[strongarm][type] = "module"
projects[strongarm][version] = "2.x"
projects[strongarm][download][type] = "git"
projects[strongarm][download][revision] = "5a2326b"
projects[strongarm][download][branch] = "7.x-2.x"

projects[theme_context][type] = "module"
projects[theme_context][download][type] = "git"
projects[theme_context][download][branch] = "7.x-1.x"
projects[theme_context][download][revision] = "ab87e22"
projects[theme_context][download][url] = "git://git.drupal.org/sandbox/netbek/2420451.git"

projects[timeperiod][type] = "module"
projects[timeperiod][version] = "1.0-beta1"

projects[token][type] = "module"
projects[token][version] = "1.6"

projects[transliteration][type] = "module"
projects[transliteration][version] = "3.2"

projects[username_enumeration_prevention][type] = "module"
projects[username_enumeration_prevention][version] = "1.1"
projects[username_enumeration_prevention][patch][2401613] = "https://www.drupal.org/files/issues/username-2483015-2.patch"

projects[views][type] = "module"
projects[views][version] = "3.11"

projects[views_php][type] = "module"
projects[views_php][version] = "2.x"
projects[views_php][download][type] = "git"
projects[views_php][download][revision] = "c520371"
projects[views_php][download][branch] = "7.x-2.x"

projects[wysiwyg_filter][type] = "module"
projects[wysiwyg_filter][version] = "1.x"
projects[wysiwyg_filter][download][type] = "git"
projects[wysiwyg_filter][download][revision] = "6c4c920"
projects[wysiwyg_filter][download][branch] = "7.x-1.x"
projects[wysiwyg_filter][patch][2575617] = "https://www.drupal.org/files/issues/wysiwyg_filter-support_media_attribute_validation-2575617-1.patch"

projects[xmlsitemap][type] = "module"
projects[xmlsitemap][version] = "2.2"



; Libraries
libraries[ckeditor][download][type] = "get"
libraries[ckeditor][download][url] = "http://download.cksource.com/CKEditor/CKEditor/CKEditor%204.4.8/ckeditor_4.4.8_full.tar.gz"
libraries[ckeditor][directory_name] = "ckeditor"
libraries[ckeditor][type] = "library"

; libraries[ckeditor_dialogui][download][type] = "get"
; libraries[ckeditor_dialogui][download][url] = "http://download.ckeditor.com/dialogui/releases/dialogui_4.4.8.zip"
; libraries[ckeditor_dialogui][directory_name] = "ckeditor/plugins/dialogui"
; libraries[ckeditor_dialogui][type] = "library"

; libraries[ckeditor_image2][download][type] = "get"
; libraries[ckeditor_image2][download][url] = "http://download.ckeditor.com/image2/releases/image2_4.4.8.zip"
; libraries[ckeditor_image2][directory_name] = "ckeditor/plugins/image2"
; libraries[ckeditor_image2][type] = "library"

libraries[ckeditor_lineutils][download][type] = "get"
libraries[ckeditor_lineutils][download][url] = "http://download.ckeditor.com/lineutils/releases/lineutils_4.4.8.zip"
libraries[ckeditor_lineutils][directory_name] = "ckeditor/plugins/lineutils"
libraries[ckeditor_lineutils][type] = "library"

libraries[ckeditor_widget][download][type] = "get"
libraries[ckeditor_widget][download][url] = "http://download.ckeditor.com/widget/releases/widget_4.4.8.zip"
libraries[ckeditor_widget][directory_name] = "ckeditor/plugins/widget"
libraries[ckeditor_widget][type] = "library"

libraries[plupload][download][type] = "get"
libraries[plupload][download][url] = "https://github.com/moxiecode/plupload/archive/v1.5.8.zip"
libraries[plupload][directory_name] = "plupload"
libraries[plupload][type] = "library"
libraries[plupload][patch][1903850] = "http://drupal.org/files/issues/plupload-1_5_8-rm_examples-1903850-16.patch"



; Themes
projects[adminimal_theme][type] = "theme"
projects[adminimal_theme][version] = "1.22"

projects[chiron][type] = "theme"
projects[chiron][download][type] = "git"
projects[chiron][download][branch] = "7.x-1.x"
projects[chiron][download][url] = "https://github.com/liquidfridge/chiron.git"

projects[hyperion][type] = "theme"
projects[hyperion][download][type] = "git"
projects[hyperion][download][branch] = "7.x-1.x"
projects[hyperion][download][url] = "https://github.com/liquidfridge/hyperion.git"

projects[omega][type] = "theme"
projects[omega][version] = "4.4"
projects[omega][patch][] = "https://raw.github.com/netbek/drupal-patches/7.x/contrib/omega/omega-remove_js_source_maps.patch"
