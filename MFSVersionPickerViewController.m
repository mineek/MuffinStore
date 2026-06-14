#import "MFSVersionPickerViewController.h"

@interface MFSVersionPickerViewController () <UISearchResultsUpdating>
@property(nonatomic, strong) NSArray *versions;
@property(nonatomic, strong) NSArray *filteredVersions;
@property(nonatomic, strong) UISearchController *searchController;
@end

@implementation MFSVersionPickerViewController

- (instancetype)initWithVersions:(NSArray *)versions
					  completion:(MFSVersionPickerCompletion)completion
{
	self = [super initWithStyle:UITableViewStyleInsetGrouped];
	if (self)
	{
		_versions = versions ?: @[];
		_filteredVersions = _versions;
		_completionHandler = completion;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Select Version";
	[self.tableView registerClass:[UITableViewCell class]
		   forCellReuseIdentifier:@"VersionCell"];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
		initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
							 target:self
							 action:@selector(cancelTapped)];
	self.navigationItem.leftBarButtonItem = cancelButton;

	self.searchController =
		[[UISearchController alloc] initWithSearchResultsController:nil];
	self.searchController.searchResultsUpdater = self;
	self.searchController.obscuresBackgroundDuringPresentation = NO;
	self.searchController.searchBar.placeholder = @"Search versions";

	self.navigationItem.searchController = self.searchController;
	self.navigationItem.hidesSearchBarWhenScrolling = NO;
	self.definesPresentationContext = YES;
}

- (void)cancelTapped
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateSearchResultsForSearchController:
	(UISearchController *)searchController
{
	NSString *query = searchController.searchBar.text;

	if (query.length == 0)
	{
		self.filteredVersions = self.versions;
		[self.tableView reloadData];
		return;
	}

	NSString *needle = query.lowercaseString;
	NSMutableArray *results = [NSMutableArray array];

	for (NSDictionary *version in self.versions)
	{
		NSString *bundleVersion = [NSString
			stringWithFormat:@"%@", version[@"bundle_version"] ?: @""];
		NSString *externalIdentifier = [NSString
			stringWithFormat:@"%@", version[@"external_identifier"] ?: @""];

		NSString *haystack =
			[[NSString stringWithFormat:@"%@ %@", bundleVersion,
										externalIdentifier] lowercaseString];

		if ([haystack containsString:needle])
		{
			[results addObject:version];
		}
	}

	self.filteredVersions = results;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section
{
	return self.filteredVersions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	UITableViewCell *cell =
		[tableView dequeueReusableCellWithIdentifier:@"VersionCell"
										forIndexPath:indexPath];

	NSDictionary *version = self.filteredVersions[indexPath.row];
	cell.textLabel.text = version[@"bundle_version"];
	cell.textLabel.font =
		[UIFont monospacedDigitSystemFontOfSize:15 weight:UIFontWeightRegular];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView
	didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *selected = self.filteredVersions[indexPath.row];
	[self dismissViewControllerAnimated:YES
							 completion:^{
							   if (self.completionHandler)
							   {
								   self.completionHandler(selected);
							   }
							 }];
}

- (NSString *)tableView:(UITableView *)tableView
	titleForHeaderInSection:(NSInteger)section
{
	if (self.searchController.searchBar.text.length > 0)
	{
		return [NSString
			stringWithFormat:@"%lu of %lu versions",
							 (unsigned long)self.filteredVersions.count,
							 (unsigned long)self.versions.count];
	}

	return [NSString stringWithFormat:@"%lu versions available",
									  (unsigned long)self.versions.count];
}

@end
