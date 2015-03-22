<?php 

require_once 'alchemyapi.php';
$alchemyapi = new AlchemyAPI();

//$demo_text = "Dylan is born in Duluth.";
$demo_text = $_POST['text'];


$response = $alchemyapi->concepts('text',$demo_text, null);

if ($response['status'] == 'OK') {
	//echo '## Response Object ##', '<br>';
	//echo print_r($response);

	//echo '<br>';
	//echo '## Concepts ##', '<br>';
	foreach ($response['concepts'] as $concept) {
		//echo 'concept: ', $concept['text'], '<br>';
		//echo 'relevance: ', $concept['relevance'], '<br>';
		//echo 'dbpedia: ', $concept['dbpedia'], '<br>';
		//echo '<br>';

		//DBPedia
		if(array_key_exists('dbpedia',$concept)){
			$requestUrl = getUrlDbpediaAbstractURL($concept['dbpedia']);
			$resultArray = request($requestUrl);
			$resultArray = json_decode($resultArray,true);
			if(!empty($resultArray['results']["bindings"])){
            echo '<h2>',$concept['text'], '</h2><br>';
				echo $resultArray['results']["bindings"][0]["abstract"]["value"];
            echo '<br>';
			}
		}
	}
} else {
	echo 'Error in the concept tagging call: ', $response['statusInfo'];
}

//url with query for DBPedia
function getUrlDbpediaAbstract($term){
   $format = 'json';

   $query = 
   "PREFIX dbp: <http://dbpedia.org/resource/>
   PREFIX dbp2: <http://dbpedia.org/ontology/>
 
   SELECT ?abstract
   WHERE {
      dbp:".$term." dbp2:abstract ?abstract . 
      FILTER langMatches(lang(?abstract), 'en')
   }";
   
   $searchUrl = 'http://dbpedia.org/sparql?'
      .'query='.urlencode($query)
      .'&format='.$format;

   return $searchUrl;
}

//Same function as above, but uses direct DBPedia URL (better!)
function getUrlDbpediaAbstractURL($url){
   $format = 'json';

   $query = 
   "PREFIX dbp: <http://dbpedia.org/resource/>
   PREFIX dbp2: <http://dbpedia.org/ontology/>
 
   SELECT ?abstract
   WHERE {
      <".$url."> dbp2:abstract ?abstract . 
      FILTER langMatches(lang(?abstract), 'en')
   }";
   
   $searchUrl = 'http://dbpedia.org/sparql?'
      .'query='.urlencode($query)
      .'&format='.$format;

   return $searchUrl;
}

//Posts with cURL
function request($url){
 
   // is curl installed?
   if (!function_exists('curl_init')){ 
      die('CURL is not installed!');
   }
   
   // get curl handle
   $ch= curl_init();

   // set request url
   curl_setopt($ch, 
      CURLOPT_URL, 
      $url);

   // return response, don't print/echo
   curl_setopt($ch, 
      CURLOPT_RETURNTRANSFER, 
      true);
 
   $response = curl_exec($ch);
   
   curl_close($ch);
   
   return $response;
}

//Prints an array neatly
function printArray($array, $spaces = ""){
   $retValue = "";
   
   if(is_array($array))
   {  
      $spaces = $spaces
         ."&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

      $retValue = $retValue."<br/>";

      foreach(array_keys($array) as $key)
      {
         $retValue = $retValue.$spaces
            ."<strong>".$key."</strong>"
            .printArray($array[$key], 
               $spaces);
      }     
      $spaces = substr($spaces, 0, -30);
   }
   else $retValue = 
      $retValue." - ".$array."<br/>";
   
   return $retValue;
}
?>
