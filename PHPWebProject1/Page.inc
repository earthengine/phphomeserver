<?php header("content-type: text/html; charset=utf-8"); ?><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title><?php print $page_title; ?></title>
    <link type="text/css" rel="stylesheet" href="Main.css">
	<meta content="text/html; charset=utf-8">
</head>
<body>
	<div id="wrapper">
		<div id="banner">
			<h1><?php echo $bannerText; ?></h1>
		</div>
		<div id="nav">
            <a href="indexEnglish.php">英文</a>
			<a href="indexChinese.php">Chinese</a>
        </div>
<?php echo $page_content; ?>
        <div id="footer">&copy;2013 Earth Engine</div>
    </div>
</body>
</html>
