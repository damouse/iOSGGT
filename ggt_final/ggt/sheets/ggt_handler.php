<?php

/**
	Working version 1. Stable, functional.
	
	Call functions by appending to url. type = {login, mod, download}.
	App must deal with login details: force the login check app-side for now. 
	
	WARNING: .xlsx files are currently NOT SUPPORTED!
*/

//error posting
error_reporting(E_ALL);

ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

//9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08

/**
*	MAIN
*	This is the main logic of the script. Determine what function was called, handle appropriately. 
*/

//login. Currently only one account is enabled and hardcoded; without access to read/write permissions thats about it. 
$type = $_GET['type'];

if($type == "login") {
	$user = $_GET['user'];
	$pass = $_GET['pass'];
	
	if($user == "admin" && $pass == "adminbasepassword") {
		$userObject = array(
			'id' => 1,
			'user' => 'admin',
		); //consider returning time of access, possibly to check time last updated?
		
		$return = array(
			'type' => 'login',
			'data' => $userObject,
			'status' => 'success'
		);
		
		echo json_encode($return);
	}
	else {
			$return = array(
			'type' => 'login',
			'status' => 'fail'
		);
		
		echo json_encode($return);
	}
	
	//cs servers do not allow this script to create files, so passwords are temporarily hardcoded
}

/**
* Returns all files in the current directory along with their last-modified times. Allows for fine-grained downloading, may increase
* performance if there are a lot of sheets in the dir. 
*/
if($type == "mod") {
	returnModifiedTimes ();
}

/** parse and download function. 
 Note: this is not secure; it relies on obscurity to remain secure. If anyone gets the URL and 
 looks at the source code for the iOS project, they can go to the URL and access any excel files there. The ONLY way to prevent
 this is with use of an admin account to be able to write hashed passwords to file, double-check against users. 
 HOWEVER: this would rely on some great timing and dedicated, malicious effort from an attacker: they would have to watch
 network traffic from the app's device; simply downloading the app would not be enough.
*/
if($type == "download") {
	$fileName = $_GET['fname'];
	$key = $_GET['key'];
	
	parseReturnFile ($fileName, $key);
}

/**
* Currently just a testing, but it looks like this should properly display last time a file was modified
*/
function returnModifiedTimes () {

	$spreadsheets = array();
	
	foreach (glob("*.enc") as $inputFileName) {
		
		if(substr($inputFileName, 0, 1) == '.') //ignore temp files
			continue;
			
		//when was this file last modified? this DOES WORK. 
		//echo $inputFileName . " " . filemtime($inputFileName) . '<br>';
		
		$tmp = filemtime($inputFileName);
		$spreadsheets[$inputFileName] = "$tmp";
	}
	
	$return = array(
		'type' => 'mod',
		'data' => $spreadsheets,
		'status' => 'success'
	);
		
	echo json_encode($return);
}


/** 
* Used by path editor to check and see if a newly added url is correct
*/ 
if($type == "ping") {
	$return = array(
		'type' => 'ping',
		'status' => 'success'
	);
		
	echo json_encode($return);
}

/**
* The main parsing function for this script. Returns the excel file requested as arrays of arrays in an associative array
* keyed by the filename. 
*
* NOTE: temporary "._." files not tested, HAVE TO LOOK AT THIS!
*/
function parseReturnFile ($inputFileName, $key) {
	//import 
	require_once '../framework/GGT_Classes/PHPExcel.php';
	
	// unix/osx create files prefixed with "._." when they have to make temporary files. I expect this to break this
	//script, so check to make sure the filename does not begin with a period.
	if(substr($inputFileName, 0, 1) == '.')
		continue;
		
	//take the name of the input file, decrypt it and save it to a temp file, parse that
	$decryptedFileName = Decrypt($inputFileName, $key);

	//load the next excel sheet
	$objPHPExcel = PHPExcel_IOFactory::load($decryptedFileName);
	$objWorksheet = $objPHPExcel->getActiveSheet();
	$outsideArray = array(); //array holding rows

	unlink($decryptedFileName);
	
	//check to make sure no more than 10 empty rows go by before quitting
	$tenEmptyRows = FALSE;
	$thisRowEmpty = FALSE;
	$emptyRows = 0;
	$hardcodedColumnLimit = 20;

	foreach ($objWorksheet->getRowIterator() as $row) {
	  	
	  	$cellIterator = $row->getCellIterator();
	  	$cellIterator->setIterateOnlyExistingCells(false); 
	  	
	  	//create the inside array
	  	$insideArray = array();
	
	  	$columnCounter = 0; //limit the number of rows calculated
	  	foreach ($cellIterator as $cell) {
	  		if($columnCounter >= 20)
	  			break;
	  			
	  		//if this is a date, then the calcVal will butcher it. Check to make sure there are no division signs
	  		if($isDate = PHPExcel_Shared_Date::isDateTime($cell) && $cell->getValue() != "") {
	  			$currentDateString = date("m/d/Y");
		  		
		  		$tempVal = PHPExcel_Shared_Date::ExcelToPHPObject($cell->getValue())->format('m/d/Y');
		  		
		  		if($tempVal == $currentDateString)
		  			$calcVal = $cell->getValue();
		  		else
		  			$calcVal = $tempVal;
		  		
	  		}
	  		else {
		  		//test for empty cells... if a certain amount of rows pass where all cells are 0, then stop
		  		$calcVal = $cell->getCalculatedValue();
		  		if($calcVal == null)
		  			$calcVal = "";
		  	}
		  	
		  	$cmp = strcmp("", $calcVal);
		  	$cmpZero = strcmp("0", $calcVal);
	  		
	  		
	  		//incrememnt empty row counter. If we only saw 0's, up the counter. 
	  		if($cmp != 0 && $cmpZero != 0) { //if the cell contains an empty string or a 0
	  			$emptyRows = 0;
	  		}
	  		
	  		$addVal = "$calcVal";
	  		//if($addVal == "")
	  		//	$addVal = " ";
	  		$insideArray[] = $addVal;
	  		
	  		$columnCounter++;
		}
		
		
		$emptyRows++;
		$outsideArray[] = $insideArray;
		 
		//if 10 empty rows have passed, break
		if($emptyRows > 10)
			break;
	}


	//time last modified
	$mod = filemtime($inputFileName);
	
	//return the JSON
		$return = array(
			'type' => 'download',
			'modTime' => $mod,
			'fileName' => $inputFileName,
			'data' => $outsideArray,
			'status' => 'success'
		);
		
	echo json_encode($return);
}


function decryptFile ($inputFileName) {
	//Decrypt the given file, save it in a temporary file location 
	//and return the name of this file 

}

function createTempFile ($fileContents) {
	//create a temporary file, fill it with the contents, return the name
	//of this file 

	$randFName = substr(md5(rand()), 0, 10);

	$tmpfname = tempnam("/tmp", $randFName);

	$handle = fopen($tmpfname, "w+");

	fwrite($handle, $fileContents);

	fclose($handle);
	return $tmpfname;

	//testing code: check the contents of the file
	/*fseek($handle, 0);
	echo fread($handle, 1024);

	//this is needed to close and remove the file 
	fclose($handle);
	unlink($tmpfname);*/
}

// Decrypt Function
function os_decrypt($decrypt, $key) {

	//iv is constant for now. I'm not sure who is going to chase down these files 
	//by comparing ciphered versions... still fix this in the next build (append iv to 
	//encrypted file)
	$iv = "1234567812345678";

	//echo "\niv in hex being used: " .strtohex ($iv);
	//echo "\nkey in hex being used: ".strtohex ($key);

	if (!extension_loaded("openssl")) {
		echo "openssl extension not loaded\n";
		return false;
	}
	else {
		$decrypted_text = openssl_decrypt($decrypt, 'aes-256-cbc', $key, true, $iv);
		return $decrypted_text;
	}

	/*
	$decoded = base64_decode($decrypt);
	$iv = mcrypt_create_iv(mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB), MCRYPT_RAND);
	$decrypted = trim(mcrypt_decrypt(MCRYPT_RIJNDAEL_256, $mc_key, trim($decoded), MCRYPT_MODE_ECB, $iv));
	return $decrypted;
	*/
}

//takes the source file name, the filename where to save the decrypted version, and the key
function Decrypt($source, $key) {
  if (is_file($source) === true) {

    //load the file, decrypt the contents
    $contents = file_get_contents($source);
    $decryptedSource = os_decrypt($contents, $key);

    //echo $key . "\n";
    //echo $contents;


    if($decryptedSource == false)
      return false;

  	return createTempFile($decryptedSource);

    //save the file
    /*if (file_put_contents($destination, $decryptedSource, LOCK_EX) !== false) {
      return true;
    }
    else {
      return false;
    }*/
  }
  else {
  	echo 'Source is not file!';
  }
}

?>
