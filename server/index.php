<!DOCTYPE html>
<html>
<head>
    <title></title>
</head>
    <?php
        if(array_key_exists('button1', $_POST)) {
            button1();
        }
        else if(array_key_exists('button2', $_POST)) {
            button2();
        }
        function button1() {
            echo "This is Button1 that is selected";
$data = array_slice(file('.sin/debug.log'), -50000);
foreach ($data as $line) {
    echo nl2br($line);
}
        }
        function button2() {
echo "just a moment ..."."<br>";
ob_flush();
flush();
$lines = `zip -q debug.zip .sin/debug.log ; curl --upload-file ./debug.zip https://transfer.sh;echo`;
echo "<a href='".$lines."'>download</a>";
        }
    ?>
    <form method="post">
        <input type="submit" name="button1"
                class="button" value="Button1" />
        <input type="submit" name="button2"
                class="button" value="Button2" />
    </form>
</head>
</html>




//php -S 0.0.0.0:8000 index.php