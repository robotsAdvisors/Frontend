param([string]$Path = 'lib\app\modules\login\views\login_view.dart')

$LF = [char]10
$c = [System.IO.File]::ReadAllText($Path)

# --- Fix 1: Password label Row (wrap children in Flexible, shorten link text) ---
$old1 = @(
    "                                  // Password label row",
    "                                  Row(",
    "                                    mainAxisAlignment:",
    "                                        MainAxisAlignment.spaceBetween,",
    "                                    children: [",
    "                                      Text(",
    "                                        'Contraseña',",
    "                                        style: theme.textTheme.bodyLarge",
    "                                            ?.copyWith(",
    "                                                fontWeight: FontWeight.w600,",
    "                                                fontSize: 13.sp),",
    "                                      ),",
    "                                      GestureDetector(",
    "                                        onTap: () => Get.snackbar(",
    "                                          'Pronto disponible',",
    "                                          'La recuperación de contraseña estará disponible próximamente.',",
    "                                          snackPosition: SnackPosition.BOTTOM,",
    "                                        ),",
    "                                        child: Text(",
    "                                          '¿Olvidaste tu contraseña?',",
    "                                          style: TextStyle(",
    "                                            color: theme.primaryColor,",
    "                                            fontSize: 12.sp,",
    "                                            fontWeight: FontWeight.w600,",
    "                                          ),",
    "                                        ),",
    "                                      ),",
    "                                    ],",
    "                                  ),"
) -join $LF

$new1 = @(
    "                                  // Password label row",
    "                                  Row(",
    "                                    mainAxisAlignment:",
    "                                        MainAxisAlignment.spaceBetween,",
    "                                    children: [",
    "                                      Flexible(",
    "                                        child: Text(",
    "                                          'Contraseña',",
    "                                          overflow: TextOverflow.ellipsis,",
    "                                          style: theme.textTheme.bodyLarge",
    "                                              ?.copyWith(",
    "                                                  fontWeight: FontWeight.w600,",
    "                                                  fontSize: 13.sp),",
    "                                        ),",
    "                                      ),",
    "                                      Flexible(",
    "                                        child: GestureDetector(",
    "                                          onTap: () => Get.snackbar(",
    "                                            'Pronto disponible',",
    "                                            'La recuperación de contraseña estará disponible próximamente.',",
    "                                            snackPosition: SnackPosition.BOTTOM,",
    "                                          ),",
    "                                          child: Text(",
    "                                            '¿Olvidaste?',",
    "                                            textAlign: TextAlign.end,",
    "                                            overflow: TextOverflow.ellipsis,",
    "                                            style: TextStyle(",
    "                                              color: theme.primaryColor,",
    "                                              fontSize: 12.sp,",
    "                                              fontWeight: FontWeight.w600,",
    "                                            ),",
    "                                          ),",
    "                                        ),",
    "                                      ),",
    "                                    ],",
    "                                  ),"
) -join $LF

if (-not $c.Contains($old1)) { throw 'Fix1: password label Row block not found.' }
$c = $c.Replace($old1, $new1)

# --- Fix 2: Admin section Row → Wrap (to avoid horizontal overflow) ---
$old2 = @(
    "            child: Row(",
    "              mainAxisSize: MainAxisSize.min,",
    "              children: [",
    "                Icon(Icons.admin_panel_settings_outlined,",
    "                    size: 15, color: Colors.grey.shade500),",
    "                7.horizontalSpace,",
    "                Text(",
    "                  '¿Eres administrador?',",
    "                  style: TextStyle(",
    "                      color: Colors.grey.shade600, fontSize: 12.sp),",
    "                ),",
    "                4.horizontalSpace,",
    "                GestureDetector(",
    "                  onTap: controller.toggleAdminPanel,",
    "                  child: Text(",
    "                    isAdmin ? 'Volver' : 'Ingresa aquí',",
    "                    style: TextStyle(",
    "                      color: theme.primaryColor,",
    "                      fontWeight: FontWeight.w700,",
    "                      fontSize: 12.sp,",
    "                    ),",
    "                  ),",
    "                ),",
    "              ],",
    "            ),"
) -join $LF

$new2 = @(
    "            child: Wrap(",
    "              alignment: WrapAlignment.center,",
    "              crossAxisAlignment: WrapCrossAlignment.center,",
    "              spacing: 6,",
    "              children: [",
    "                Icon(Icons.admin_panel_settings_outlined,",
    "                    size: 15, color: Colors.grey.shade500),",
    "                Text(",
    "                  '¿Eres administrador?',",
    "                  style: TextStyle(",
    "                      color: Colors.grey.shade600, fontSize: 12.sp),",
    "                ),",
    "                GestureDetector(",
    "                  onTap: controller.toggleAdminPanel,",
    "                  child: Text(",
    "                    isAdmin ? 'Volver' : 'Ingresa aquí',",
    "                    style: TextStyle(",
    "                      color: theme.primaryColor,",
    "                      fontWeight: FontWeight.w700,",
    "                      fontSize: 12.sp,",
    "                    ),",
    "                  ),",
    "                ),",
    "              ],",
    "            ),"
) -join $LF

if (-not $c.Contains($old2)) { throw 'Fix2: admin section Row block not found.' }
$c = $c.Replace($old2, $new2)

# --- Fix 3: Footer Row → Wrap ---
$old3 = @(
    "      child: Row(",
    "        mainAxisAlignment: MainAxisAlignment.center,",
    "        children: [",
    "          TextButton(",
    "              onPressed: () {},",
    "              style: btnStyle,",
    "              child: const Text('Términos', style: linkStyle)),",
    "          dot,",
    "          TextButton(",
    "              onPressed: () {},",
    "              style: btnStyle,",
    "              child: const Text('Privacidad', style: linkStyle)),",
    "          dot,",
    "          TextButton(",
    "              onPressed: () {},",
    "              style: btnStyle,",
    "              child: const Text('Ayuda', style: linkStyle)),",
    "        ],",
    "      ),"
) -join $LF

$new3 = @(
    "      child: Wrap(",
    "        alignment: WrapAlignment.center,",
    "        crossAxisAlignment: WrapCrossAlignment.center,",
    "        children: [",
    "          TextButton(",
    "              onPressed: () {},",
    "              style: btnStyle,",
    "              child: const Text('Términos', style: linkStyle)),",
    "          dot,",
    "          TextButton(",
    "              onPressed: () {},",
    "              style: btnStyle,",
    "              child: const Text('Privacidad', style: linkStyle)),",
    "          dot,",
    "          TextButton(",
    "              onPressed: () {},",
    "              style: btnStyle,",
    "              child: const Text('Ayuda', style: linkStyle)),",
    "        ],",
    "      ),"
) -join $LF

if (-not $c.Contains($old3)) { throw 'Fix3: footer Row block not found.' }
$c = $c.Replace($old3, $new3)

# Persist with UTF-8 (no BOM) and LF endings, matching original.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($Path, $c, $utf8NoBom)
Write-Host 'login_view.dart patched successfully.'
