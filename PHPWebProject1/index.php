<?php 
$refresh = "1,url=";
$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
if($lang=="cn") $refresh .= "indexChinese.php";
else $refresh .= "indexEnglish.php";
?>
<html>
<head>
    <meta http-equiv="refresh" content="<?php echo $refresh; ?>">
</head>
<body />
</html>