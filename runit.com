! Copyright (C) 2024 Jeffrey Getzin.
! Licensed under the GNU General Public License v3.0 with additional terms.
! See the LICENSE file in the repository root for details.

$   define/nolog Stone_Data   sys$login
$   run stonequest.exe
