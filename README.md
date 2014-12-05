Category that simplifies using of autolayout in UITableViewCell.
UITableView holds prototype of cell created using provided reuse identifier, pass in to provided configuration block to let user fill the cell with actual data. Than it calculates the size of cell according to it's constraints. Previously calculated values are cached and you can empty this cache, all or just for particular index paths.

For iOS 8 you should use self sizing cells. For iOS 8 category simply always returns UITableViewAutomaticDimension. This category is helpfull when you need to support both iOS 7 and iOS8. 
