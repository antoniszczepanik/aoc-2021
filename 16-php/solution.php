<?php 

class Packet {
    public $version = NULL;
    public $typeID = NULL;
    public $inner = array();
    public $val = NULL;
    public $lengthTypeID = NULL;
}

class ConsumedPacket {
    public $packet = NULL;
    public $rest = NULL;
}

class ConsumedValue {
    public $val = NULL;
    public $rest = NULL;
}

// This needs to be done manually, because base_convert looses precision for
// large hex numbers...
function hex2bin_str($hex_str) {
    $chars = str_split($hex_str);
    $bin_str = "";
    foreach ($chars as $char) {
        $bin_str .= str_pad(base_convert($char, 16, 2), 4, "0", STR_PAD_LEFT);
    }
    return $bin_str;
}

function read_input($path) {
    $f = fopen($path, "r") or die("");
    $input = substr(fread($f ,filesize($path)), 0, -1);
    return hex2bin_str($input);
}

function consume_packet($bin_input) {
    $packet = new Packet();
    $packet->version = bindec(substr($bin_input, 0, 3));
    $packet->typeID = bindec(substr($bin_input, 3, 3));

    $return_val = new ConsumedPacket();

    if ($packet->typeID == 4) {
        $consumed_val = parse_value(substr($bin_input, 6));
        $packet->val = bindec($consumed_val->val);

        $return_val->packet = $packet;
        $return_val->rest = $consumed_val->rest;
        return $return_val;
    }

    $packet->lengthTypeID = substr($bin_input, 6, 1);
    $rest = substr($bin_input, 7);

    if ($packet->lengthTypeID == "0") {
        $bits_in_subpacket = bindec(substr($rest, 0, 15));
        $rest = substr($rest, 15);
        $consumed_amount = 0;
        while (($bits_in_subpacket - $consumed_amount) >= 11){
            $cp = consume_packet($rest);
            $consumed_amount += (strlen($rest) - strlen($cp->rest));
            $rest = $cp->rest;
            array_push($packet->inner, $cp->packet);
        }
    }

    if ($packet->lengthTypeID == "1") {
        $subpacket_num = bindec(substr($rest, 0, 11));
        $rest = substr($rest, 11);
        for ($i = 0; $i < $subpacket_num; $i++) {
            $cp = consume_packet($rest);
            $rest = $cp->rest;
            array_push($packet->inner, $cp->packet);
        }
    }

    $return_val->packet = $packet;
    $return_val->rest = $rest;
    return $return_val;
}

function parse_value($bin_input) {
    $v = new ConsumedValue();
    if (substr($bin_input, 0, 1) == "0") {
        $v->val = substr($bin_input, 1, 4);
        $v->rest = substr($bin_input, 5);
        return $v;
    }
    $next = parse_value(substr($bin_input, 5));
    $v->val = substr($bin_input, 1, 4) . $next->val;
    $v->rest = $next->rest;
    return $v;
}

function sum_versions($packet) {
    $sum = $packet->version;
    foreach ($packet->inner as $child) {
        $sum += sum_versions($child);
    }
    return $sum;
}

function evaluate($packet) {
    switch ($packet->typeID) {
    case 0:
        $sum = 0;
        foreach ($packet->inner as $child) {
            $sum += evaluate($child);
        }
        return $sum;
    case 1:
        $product = 1;
        foreach ($packet->inner as $child) {
            $product *= evaluate($child);
        }
        return $product;
    case 2:
        $min = PHP_INT_MAX;
        foreach ($packet->inner as $child) {
            $min = min($min, evaluate($child));
        }
        return $min;
    case 3:
        $max = PHP_INT_MIN;
        foreach ($packet->inner as $child) {
            $max = max($max, evaluate($child));
        }
        return $max;
    case 4:
        return $packet->val;
    case 5:
        return +(evaluate($packet->inner[0]) > evaluate($packet->inner[1]));
    case 6:
        return +(evaluate($packet->inner[0]) < evaluate($packet->inner[1]));
    case 7:
        return +(evaluate($packet->inner[0]) == evaluate($packet->inner[1]));
    default:
        throw new Exception('Unexpected typeID');
    }
}

if (count($argv) < 2) {
    fwrite(STDERR, "Provide path of a file you'd like to solve");
    exit(1);
}

echo "Day 16:\n";
$packet = consume_packet(read_input($argv[1]))->packet;
echo "Solution 1: " . sum_versions($packet) . "\n";
echo "Solution 2: " . evaluate($packet) . "\n";

?>
