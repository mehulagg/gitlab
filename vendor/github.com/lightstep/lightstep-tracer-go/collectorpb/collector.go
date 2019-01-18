package collectorpb

func (res *ReportResponse) Disable() bool {
	for _, command := range res.GetCommands() {
		if command.Disable {
			return true
		}
	}
	return false
}
