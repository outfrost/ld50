extends Spatial

func set_max_part_index(index: int) -> void:
	$PartsBucket1.enable(index >= 0)
	$PartsBucket2.enable(index >= 1)
	$PartsBucket3.enable(index >= 2)
	$PartsBucket4.enable(index >= 3)
	$PartsBucket5.enable(index >= 4)
	$PartsBucket6.enable(index >= 5)
	$PartsBucket7.enable(index >= 6)
	$PartsBucket8.enable(index >= 7)
	$PartsBucket9.enable(index >= 8)
	$PartsBucket10.enable(index >= 9)

