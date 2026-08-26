// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SkiPass';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageBosnian => 'Bosnian';

  @override
  String get languageEnglish => 'English';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDiscard => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonNoItemsAvailable => 'No items available';

  @override
  String get errorUnableToLoadData => 'Unable to load data';

  @override
  String get commonRetry => 'Try again';

  @override
  String get reasonMinLengthError =>
      'The reason must be at least 3 characters long.';

  @override
  String get commonAll => 'All';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonNoData => 'No data';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonBuy => 'Buy';

  @override
  String get resetFiltersAction => 'Reset filters';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get cancellationReasonLabel => 'Cancellation reason';

  @override
  String discountBadge(String percent) {
    return '$percent% discount';
  }

  @override
  String get imagePickFailedMessage =>
      'Selecting the photo failed. Please try again.';

  @override
  String get removePhotoAction => 'Remove photo';

  @override
  String get paymentFailedGenericMessage => 'Payment failed. Please try again.';

  @override
  String get fieldUsernameLabel => 'Username';

  @override
  String get fieldFirstNameLabel => 'First name';

  @override
  String get fieldLastNameLabel => 'Last name';

  @override
  String get fieldEmailLabel => 'Email address';

  @override
  String get emailHintExample => 'name@domain.ba';

  @override
  String get fieldPhoneLabel => 'Phone number';

  @override
  String get fieldPhoneHint => '+387 61 123 456';

  @override
  String get fieldBirthDateLabel => 'Date of birth';

  @override
  String get dateFieldSelectHint => 'Select date';

  @override
  String get fieldCityLabel => 'City';

  @override
  String get cityDropdownHint => 'Select city';

  @override
  String get fieldPasswordLabel => 'Password';

  @override
  String get fieldNewPasswordLabel => 'New password';

  @override
  String get fieldConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get passwordMinLengthHelper => 'At least 4 characters.';

  @override
  String get showPasswordTooltip => 'Show password';

  @override
  String get hidePasswordTooltip => 'Hide password';

  @override
  String get statusOrderPending => 'Awaiting payment';

  @override
  String get statusOrderConfirmed => 'Confirmed';

  @override
  String get statusOrderCompleted => 'Completed';

  @override
  String get statusOrderCancelled => 'Cancelled';

  @override
  String get statusTicketPending => 'Inactive';

  @override
  String get statusTicketActive => 'Active';

  @override
  String get statusTicketUsed => 'In use';

  @override
  String get statusTicketExpired => 'Expired';

  @override
  String get statusIncidentReported => 'Reported';

  @override
  String get statusIncidentInProgress => 'In progress';

  @override
  String get statusIncidentResolved => 'Resolved';

  @override
  String get statusIncidentRejected => 'Rejected';

  @override
  String get statusCrowdLow => 'Light crowds';

  @override
  String get statusCrowdModerate => 'Moderate crowds';

  @override
  String get statusCrowdHigh => 'Heavy crowds';

  @override
  String get statusCrowdVeryHigh => 'Very heavy crowds';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get statusUrgentLabel => 'Urgent';

  @override
  String get navHome => 'Home';

  @override
  String get navTrails => 'Trails';

  @override
  String get navPurchase => 'Purchase';

  @override
  String get navTickets => 'Tickets';

  @override
  String get navBenefits => 'Benefits';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginHeaderTitle => 'Welcome';

  @override
  String get loginHeaderSubtitle =>
      'Sign in to buy ski pass tickets\nand check trail conditions in real time.';

  @override
  String get loginUsernameHint => 'e.g. mobile';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginForgotPasswordLink => 'Forgot password?';

  @override
  String get loginSubmitButton => 'Sign in';

  @override
  String get loginNoAccountLabel => 'Don\'t have an account?';

  @override
  String get loginRegisterLink => 'Register';

  @override
  String get registerAppBarTitle => 'Registration';

  @override
  String get registerHeading => 'Create an account';

  @override
  String get registerRequiredFieldsNote =>
      'Fields marked with an asterisk are required.';

  @override
  String get registerUsernameHint => 'e.g. skier.haris';

  @override
  String get registerPhoneHelper =>
      'Used to contact you if an incident is reported.';

  @override
  String get registerCitiesUnavailable => 'Cities are currently unavailable';

  @override
  String get fieldConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerSubmitButton => 'Create account';

  @override
  String get registerBackToLogin => 'Back to sign in';

  @override
  String get registerMinorNotice =>
      'Note: ticket purchases for minors must be confirmed by a parent or guardian.';

  @override
  String get registerSuccessMessage =>
      'Your account has been created. Welcome to SkiPass!';

  @override
  String get forgotPasswordAppBarTitle => 'Password reset';

  @override
  String get forgotPasswordHeadingReset => 'Enter your new password';

  @override
  String get forgotPasswordHeadingRequest => 'Forgot password';

  @override
  String get forgotPasswordSubtitleReset =>
      'Enter the code you received and choose a new password.';

  @override
  String get forgotPasswordSubtitleRequest =>
      'Enter the email address you registered with and we\'ll send you a password reset code.';

  @override
  String get forgotPasswordSendCodeButton => 'Send code';

  @override
  String get forgotPasswordCodeSentInfo =>
      'If the address is registered, we\'ve sent a password reset code.';

  @override
  String get forgotPasswordResetCodeLabel => 'Reset code';

  @override
  String get forgotPasswordSetNewButton => 'Set new password';

  @override
  String get forgotPasswordResendOtherAddress =>
      'Send code to a different address';

  @override
  String get forgotPasswordSuccessMessage =>
      'Your password has been changed. Sign in with your new password.';

  @override
  String get devNoticeTitle => 'Development environment';

  @override
  String get devNoticeCopyTooltip => 'Copy code';

  @override
  String get devNoticeBody =>
      'The code has been filled in automatically because the email service isn\'t active yet. In production the code arrives by email.';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeDefaultUserName => 'Skier';

  @override
  String homeResortOpenUntil(String time) {
    return 'Open today until $time';
  }

  @override
  String homeResortClosed(String opening, String closing) {
    return 'Closed - business hours $opening - $closing';
  }

  @override
  String get homeCurrentOnTrail => 'Currently on the trail';

  @override
  String homeSnowDepthLabel(int cm) {
    return '$cm cm of snow';
  }

  @override
  String get homeLatestAnnouncements => 'Latest announcements';

  @override
  String get homeNoActiveAnnouncements =>
      'There are currently no active announcements.';

  @override
  String get homeFeaturedBenefits => 'Featured benefits';

  @override
  String get homeNoFeaturedBenefits =>
      'There are currently no featured benefits.';

  @override
  String get homeRecommendedTitle => 'Recommended for you';

  @override
  String get homeNoRecommendations =>
      'We don\'t have any recommendations for you yet.';

  @override
  String recommendationReasonPurchasedCategory(String category) {
    return 'Because you\'ve previously bought from $category';
  }

  @override
  String recommendationReasonViewedCategory(String category) {
    return 'Because you often browse $category';
  }

  @override
  String recommendationReasonUsedPartner(String partner) {
    return 'Because you\'ve used $partner\'s services';
  }

  @override
  String recommendationReasonPreferredBrand(String brand) {
    return 'Because you prefer the $brand brand';
  }

  @override
  String get recommendationReasonPopularFallback => 'Popular among users';

  @override
  String get homeTrailsOpenLabel => 'open';

  @override
  String get homeLiftsCardTitle => 'Ski lifts';

  @override
  String get homeLiftsOperationalLabel => 'operating';

  @override
  String homeActiveTicketsMessage(String count) {
    return 'You have $count for today';
  }

  @override
  String get homeNoActiveTicketMessage => 'You don\'t have an active ticket';

  @override
  String get homeShowQrHint => 'Show the QR code at the lift entrance.';

  @override
  String get homeBuyTicketHint => 'Buy a ski pass and hit the slopes.';

  @override
  String get homeQrCodeButton => 'QR code';

  @override
  String get trailsAppBarTitle => 'Trails and lifts';

  @override
  String get trailsSearchHint => 'Search trails by name or code';

  @override
  String get trailsFilterOpen => 'Open';

  @override
  String get liftsFilterAll => 'All';

  @override
  String get liftsFilterOperational => 'Operating';

  @override
  String get liftsFilterNonOperational => 'Not operating';

  @override
  String get trailsEmptyTitle => 'No trails match these filters';

  @override
  String get trailsEmptyMessageFiltered =>
      'Try changing your search or filters.';

  @override
  String get trailsEmptyMessageNone =>
      'No trails have been added to the system yet.';

  @override
  String get trailMetricLength => 'Length';

  @override
  String get trailMetricElevation => 'Elevation change';

  @override
  String get trailMetricSnow => 'Snow';

  @override
  String get trailNightSkiingLabel => 'Night skiing';

  @override
  String trailIncidentReportsCount(int count) {
    return '$count reports';
  }

  @override
  String get liftsEmptyTitle => 'No lifts match these filters';

  @override
  String get liftsEmptyMessage => 'Change the filter to see other lifts.';

  @override
  String liftRideDurationSuffix(int minutes) {
    return '$minutes min ride';
  }

  @override
  String liftCurrentRiders(int count) {
    return '$count riders currently';
  }

  @override
  String liftCapacityLabel(int capacity) {
    return 'Capacity $capacity/h';
  }

  @override
  String get liftOutOfServiceNotice =>
      'The lift is out of service due to a reported fault. Maintenance is in progress.';

  @override
  String get trailDetailsDefaultTitle => 'Trail details';

  @override
  String get trailReportProblemButton => 'Report a problem';

  @override
  String get trailAboutSectionTitle => 'About the trail';

  @override
  String get trailConditionsHistoryTitle => 'Condition history';

  @override
  String get trailNoConditionsRecorded =>
      'No conditions have been recorded for this trail yet.';

  @override
  String get trailReviewsTitle => 'Trail reviews';

  @override
  String get trailCodeLabel => 'Trail code';

  @override
  String get trailCrowdLabel => 'Estimated crowd level';

  @override
  String get trailSnowCoverLabel => 'Snow cover';

  @override
  String get trailSnowmakingLabel => 'Artificial snow';

  @override
  String get benefitsSearchHint => 'Search for a benefit, service, or brand';

  @override
  String get myBenefitsTitle => 'My benefits';

  @override
  String get benefitsEmptyTitle => 'No benefits match these filters';

  @override
  String get benefitsEmptyMessage =>
      'Try a different search or choose another category.';

  @override
  String get benefitNotYetRated => 'Not yet rated';

  @override
  String get benefitDetailsDefaultTitle => 'Benefit details';

  @override
  String get benefitPurchaseConfirmTitle => 'Confirm purchase';

  @override
  String benefitPurchaseConfirmMessage(
    int quantity,
    String name,
    String total,
  ) {
    return 'Buy $quantity × $name for a total of $total?';
  }

  @override
  String benefitPurchaseSuccessMessage(String name) {
    return '$name has been purchased successfully. You can find it under \"My benefits\".';
  }

  @override
  String benefitRatingsSummary(String average, int count) {
    return '$average · $count ratings';
  }

  @override
  String get benefitCategoryLabel => 'Category';

  @override
  String get benefitPartnerLabel => 'Partner';

  @override
  String get benefitBrandLabel => 'Brand';

  @override
  String get benefitRegularPriceLabel => 'Regular price';

  @override
  String get benefitDiscountedPriceLabel => 'Discounted price';

  @override
  String get benefitDescriptionSectionTitle => 'Description';

  @override
  String get benefitInactiveNotice =>
      'This benefit is currently unavailable for purchase.';

  @override
  String get benefitUserReviewsTitle => 'User reviews';

  @override
  String get benefitQuantityLabel => 'Quantity';

  @override
  String get benefitCancelPurchaseTitle => 'Cancel purchase';

  @override
  String benefitCancelSuccessMessage(String name) {
    return 'The purchase \"$name\" has been cancelled.';
  }

  @override
  String get myBenefitsEmptyTitle => 'You haven\'t purchased any benefits yet';

  @override
  String get myBenefitsEmptyMessage =>
      'Equipment rental, lessons, and dining options are available in the Benefits section.';

  @override
  String benefitCancellationReasonLine(String reason) {
    return 'Cancellation reason: $reason';
  }

  @override
  String get benefitCancelPurchaseButton => 'Cancel purchase';

  @override
  String get myIncidentsAppBarTitle => 'My reports';

  @override
  String get incidentNewReportButton => 'New report';

  @override
  String get incidentStatusReportedFilter => 'Reported';

  @override
  String get incidentStatusResolvedFilter => 'Resolved';

  @override
  String get incidentStatusRejectedFilter => 'Rejected';

  @override
  String get incidentsEmptyTitleNone => 'You have no reported incidents';

  @override
  String get incidentsEmptyTitleFiltered => 'No reports with this status';

  @override
  String get incidentsEmptyMessage =>
      'If you notice a problem on a trail or lift, report it so staff can respond.';

  @override
  String get incidentRejectionReasonTitle => 'Rejection reason';

  @override
  String get incidentStaffNoteTitle => 'Staff notes';

  @override
  String get reportIncidentAppBarTitle => 'Report an incident';

  @override
  String get selectIncidentTypeError => 'Select an incident type.';

  @override
  String get selectTrailError => 'Select the trail this report is about.';

  @override
  String get selectLiftError => 'Select the ski lift this report is about.';

  @override
  String get incidentReportSuccessMessage =>
      'Your report has been submitted. Resort staff has been notified.';

  @override
  String get coordinatesInvalidFormatError =>
      'The coordinates are not in a valid format.';

  @override
  String get incidentEmptyTitle => 'Reporting is currently unavailable';

  @override
  String get incidentEmptyMessage =>
      'Incident types haven\'t been defined in the system yet.';

  @override
  String get incidentSafetyNotice =>
      'In case of serious injury, call emergency services immediately. This report is used to notify resort staff.';

  @override
  String get incidentTypeLabel => 'Incident type';

  @override
  String get incidentLocationLabel => 'Incident location';

  @override
  String get targetTrailLabel => 'Trail';

  @override
  String get targetLiftLabel => 'Ski lift';

  @override
  String get trailsUnavailableHint => 'Trails unavailable';

  @override
  String get liftsUnavailableHint => 'Lifts unavailable';

  @override
  String get problemDescriptionLabel => 'Problem description';

  @override
  String get problemDescriptionHint =>
      'Describe what happened and exactly where.';

  @override
  String get minTenCharsHelper => 'At least 10 characters.';

  @override
  String get submitReportButton => 'Submit report';

  @override
  String get coordinatesFieldTitle => 'Location coordinates';

  @override
  String get coordinatesFieldSubtitle =>
      'Choose the nearest point or enter exact coordinates.';

  @override
  String get knownSpotBase => 'Resort base';

  @override
  String get knownSpotMiddle => 'Middle of the trail';

  @override
  String get knownSpotTop => 'Top of the trail';

  @override
  String get knownSpotLiftStart => 'Lift base station';

  @override
  String get geoLatitudeName => 'Latitude';

  @override
  String get geoLongitudeName => 'Longitude';

  @override
  String coordinateRequiredError(String name) {
    return '$name is required.';
  }

  @override
  String get coordinateFormatError => 'Enter a number in the format 43.7107';

  @override
  String coordinateRangeError(String name, int min, int max) {
    return '$name must be between $min and $max.';
  }

  @override
  String get photoSectionTitle => 'Photo (optional)';

  @override
  String get cameraButton => 'Camera';

  @override
  String get galleryButton => 'Gallery';

  @override
  String get notificationsAppBarTitle => 'Notifications';

  @override
  String get markAllReadAction => 'Mark all read';

  @override
  String get markAllReadSuccessMessage =>
      'All notifications have been marked as read.';

  @override
  String get notificationsEmptyTitle => 'You have no notifications';

  @override
  String get notificationsEmptyMessage =>
      'Notifications about orders, payments, and reports will appear on this screen.';

  @override
  String get ordersAppBarTitle => 'Order history';

  @override
  String get orderStatusConfirmedFilter => 'Confirmed';

  @override
  String get orderStatusCompletedFilter => 'Completed';

  @override
  String get orderStatusCancelledFilter => 'Cancelled';

  @override
  String get ordersEmptyTitleNone => 'You don\'t have any orders yet';

  @override
  String get ordersEmptyTitleFiltered => 'No orders with this status';

  @override
  String get ordersEmptyMessageNone =>
      'Once you buy a ski pass ticket, the order will appear here.';

  @override
  String get ordersEmptyMessageFiltered =>
      'Change the filter to see other orders.';

  @override
  String get orderDetailsDefaultTitle => 'Order details';

  @override
  String get orderCancelTitle => 'Cancel order';

  @override
  String get orderCancelButton => 'Cancel order';

  @override
  String orderCancelSuccessMessage(String orderNumber) {
    return 'Order $orderNumber has been cancelled.';
  }

  @override
  String get paymentReceivedMessage => 'Payment received.';

  @override
  String get orderTicketCountLabel => 'Number of tickets';

  @override
  String get orderPaymentMethodLabel => 'Payment method';

  @override
  String get orderTotalAmountLabel => 'Total amount';

  @override
  String get orderPaidLabel => 'Paid';

  @override
  String get orderRefundedLabel => 'Refunded';

  @override
  String get orderAwaitingPaymentNotice =>
      'The order is awaiting recorded payment. Tickets become active as soon as payment is confirmed at the ticket office or in the app.';

  @override
  String get orderPayNowButton => 'Pay for order';

  @override
  String get paymentsHistoryTitle => 'Payment history';

  @override
  String get paymentNotCompleted => 'Not completed';

  @override
  String get ticketsInOrderTitle => 'Tickets in this order';

  @override
  String get paymentStatusPartiallyRefunded => 'Partially refunded';

  @override
  String get paymentStatusFailed => 'Failed';

  @override
  String get logoutDialogTitle => 'Sign out';

  @override
  String get logoutDialogMessage => 'Are you sure you want to sign out?';

  @override
  String get logoutConfirmButton => 'Sign out';

  @override
  String get myActivitiesSectionTitle => 'My activity';

  @override
  String orderCountSubtitle(int count) {
    return '$count orders';
  }

  @override
  String get myBenefitsMenuSubtitle => 'Purchased services and equipment';

  @override
  String get myReportsMenuSubtitle => 'Reported incidents';

  @override
  String get notificationsMenuSubtitle =>
      'Notifications about orders and reports';

  @override
  String get resortAnnouncementsMenuTitle => 'Resort announcements';

  @override
  String get resortAnnouncementsMenuSubtitle =>
      'Weather conditions, promotions, and closures';

  @override
  String get accountSettingsSectionTitle => 'Account settings';

  @override
  String get editProfileMenuTitle => 'Edit profile';

  @override
  String get editProfileMenuSubtitle => 'Personal details and photo';

  @override
  String get changePasswordMenuSubtitle =>
      'Requires confirming your current password';

  @override
  String get appVersionFooter => 'SkiPass · version 1.0.0';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profilePhoneNotSet => 'Not provided';

  @override
  String get profileCityNotSet => 'Not selected';

  @override
  String get profileMemberSinceLabel => 'Member since';

  @override
  String get editProfileAppBarTitle => 'Edit profile';

  @override
  String get profileUpdateSuccessMessage => 'Profile updated successfully.';

  @override
  String get editProfileCitiesUnavailable => 'Cities unavailable';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get pickerCameraOption => 'Take a photo';

  @override
  String get pickerGalleryOption => 'Choose from gallery';

  @override
  String get changePasswordAppBarTitle => 'Change password';

  @override
  String get changePasswordSecurityNotice =>
      'For security reasons, changing your password invalidates all active sessions, so you\'ll need to sign in again.';

  @override
  String get changePasswordConfirmDialogMessage =>
      'After changing your password you\'ll be signed out of all devices. Continue?';

  @override
  String get changePasswordConfirmButton => 'Change';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get changePasswordSubmitButton => 'Change password';

  @override
  String get changePasswordSuccessMessage =>
      'Your password has been changed. Please sign in again.';

  @override
  String get purchaseAppBarTitle => 'Buy a ticket';

  @override
  String get selectTicketTypeError => 'Select a ticket type.';

  @override
  String get selectStartDateError => 'Select the ticket\'s start date.';

  @override
  String get maxTicketsPerOrderError =>
      'You can buy at most 20 tickets in a single order.';

  @override
  String get ticketsAddedToCartMessage =>
      'Tickets have been added to your cart. Enter the holder names before submitting the order.';

  @override
  String get emptyCartError => 'Your cart is empty. Add at least one ticket.';

  @override
  String get selectPaymentMethodError => 'Select a payment method.';

  @override
  String missingHolderNameError(int number) {
    return 'Enter the first and last name of the holder for ticket number $number.';
  }

  @override
  String get orderConfirmTitle => 'Confirm order';

  @override
  String orderConfirmMessage(String tickets, String total) {
    return 'Order $tickets for a total of $total?';
  }

  @override
  String get orderPlaceButton => 'Place order';

  @override
  String get paymentCancelledMessage =>
      'Payment was cancelled. The order has been saved and is awaiting payment.';

  @override
  String get paymentFailedRetryFromOrdersMessage =>
      'Payment failed. Please try again from Orders.';

  @override
  String get purchaseUnavailableTitle => 'Purchases are currently unavailable';

  @override
  String get purchaseUnavailableMessage =>
      'The resort hasn\'t published ski pass pricing yet. Please try again later.';

  @override
  String get newTicketSectionTitle => 'New ticket';

  @override
  String get ticketTypeLabel => 'Ticket type';

  @override
  String ticketTypePriceOption(String name, String price) {
    return '$name · $price/day';
  }

  @override
  String get startDateLabel => 'Start date';

  @override
  String get daysCountLabel => 'Number of days';

  @override
  String maxDaysAllowedHelper(String days) {
    return 'The selected ticket type allows at most $days.';
  }

  @override
  String get ticketsCountLabel => 'Number of tickets';

  @override
  String get multipleTicketsHelper =>
      'Buy multiple tickets at once for family or a group.';

  @override
  String get addToCartButton => 'Add to cart';

  @override
  String cartSectionTitle(String count) {
    return 'Cart ($count)';
  }

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get paymentMethodsUnavailableHint => 'Payment methods unavailable';

  @override
  String get submitOrderButton => 'Submit order';

  @override
  String get pricePerTicketLabel => 'Price per ticket';

  @override
  String totalForTicketsLabel(String tickets) {
    return 'Total for $tickets';
  }

  @override
  String get removeTicketTooltip => 'Remove ticket';

  @override
  String get ticketHolderFirstNameLabel => 'Holder\'s first name';

  @override
  String get orderConfirmationAppBarTitle => 'Order submitted';

  @override
  String get orderReceivedTitle => 'Your order has been received';

  @override
  String orderNumberLabel(String number) {
    return 'Order number: $number';
  }

  @override
  String get orderStatusLabel => 'Order status';

  @override
  String get orderDateLabel => 'Order date';

  @override
  String get purchasedTicketsTitle => 'Purchased tickets';

  @override
  String get ticketsAwaitingPaymentTitle =>
      'Tickets are awaiting payment confirmation';

  @override
  String get ticketsAwaitingPaymentBody =>
      'Once payment is recorded, tickets become active and the QR code can be used at the lift entrance.';

  @override
  String get backToPurchaseButton => 'Back to purchases';

  @override
  String get reviewThanksMessage => 'Thanks for your rating!';

  @override
  String get reviewUpdatedMessage => 'Your review has been updated.';

  @override
  String get reviewDeleteTitle => 'Delete review';

  @override
  String get reviewDeleteMessage =>
      'Are you sure you want to delete your review?';

  @override
  String get reviewDeleteSuccessMessage => 'Your review has been deleted.';

  @override
  String get reviewNoRatingsYet => 'No ratings yet. Be the first to rate.';

  @override
  String reviewsCountLabel(int count) {
    return '$count user ratings';
  }

  @override
  String get leaveReviewButton => 'Leave a review';

  @override
  String get editReviewButton => 'Edit review';

  @override
  String get deleteReviewTooltip => 'Delete review';

  @override
  String get yourReviewTitle => 'Your review';

  @override
  String get closeTooltip => 'Close';

  @override
  String get reviewCommentHint => 'Share your experience (optional)';

  @override
  String get saveReviewButton => 'Save review';

  @override
  String get myTicketsAppBarTitle => 'My tickets';

  @override
  String get orderHistoryTooltip => 'Order history';

  @override
  String get activeTicketsTab => 'Active';

  @override
  String get allTicketsTab => 'All tickets';

  @override
  String get noActiveTicketsTitle => 'You have no active tickets';

  @override
  String get noActiveTicketsMessage =>
      'Buy a ski pass ticket and it will appear here with its QR code.';

  @override
  String get noPurchasedTicketsTitle =>
      'You haven\'t purchased any tickets yet';

  @override
  String get noPurchasedTicketsMessage =>
      'All purchased tickets, including expired ones, will be shown here.';

  @override
  String get loadMoreButton => 'Load more';

  @override
  String get ticketHolderLabel => 'Holder';

  @override
  String get ticketValidLabel => 'Valid';

  @override
  String get ticketDurationLabel => 'Duration';

  @override
  String get ticketScansLabel => 'Scans';

  @override
  String get showQrButton => 'Show QR code';

  @override
  String get ticketUnavailablePending =>
      'The QR code becomes available once payment is recorded.';

  @override
  String get ticketUnavailableCancelled =>
      'The ticket has been cancelled and cannot be used.';

  @override
  String ticketUnavailableExpired(String date) {
    return 'The ticket expired on $date.';
  }

  @override
  String ticketNotYetValid(String date) {
    return 'The ticket becomes valid on $date.';
  }

  @override
  String ticketNoLongerValid(String date) {
    return 'The ticket was valid until $date.';
  }

  @override
  String get ticketUnavailableGeneric => 'The ticket is currently unusable.';

  @override
  String orderLinkLabel(String number) {
    return 'Order $number';
  }

  @override
  String get orderAwaitingPaymentBadge => 'Awaiting recorded payment';

  @override
  String get ticketQrAppBarTitle => 'Ticket QR code';

  @override
  String get copyCodeTooltip => 'Copy ticket code';

  @override
  String get codeCopiedMessage => 'Ticket code copied.';

  @override
  String get showCodeInstruction =>
      'Show this code to staff at the lift entrance.';

  @override
  String get ticketHolderLabelFull => 'Ticket holder';

  @override
  String get skiResortLabel => 'Resort';

  @override
  String get scanCountLabel => 'Number of scans';

  @override
  String get lastScanLabel => 'Last scan';

  @override
  String get announcementsAppBarTitle => 'Announcements';

  @override
  String get showAllAnnouncementsTooltip => 'Show all announcements';

  @override
  String get showUrgentOnlyTooltip => 'Show urgent only';

  @override
  String get noUrgentAnnouncementsTitle => 'No urgent announcements';

  @override
  String get noActiveAnnouncementsTitle => 'No active announcements';

  @override
  String get announcementsEmptyMessage =>
      'Announcements about weather, trail closures, and promotions will appear here.';

  @override
  String get readMoreLabel => 'Read more';

  @override
  String get announcementDetailsAppBarTitle => 'Announcement';

  @override
  String get announcementUrgentBadge => 'Urgent announcement';

  @override
  String get announcementPublishedByLabel => 'Published by';

  @override
  String get announcementValidUntilLabel => 'Valid until';
}
