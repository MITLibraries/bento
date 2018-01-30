# Why does this module exist?
# 1) We display processing status information in our record page.
# 2) We can't just pass through that status information from Aleph, because
#    sometimes it is not patron-readable
# Therefore we need to be able to map what Aleph says to what we want to tell
# people.
#
# Additional wrinkles:
# 1) Some items have processing status codes (<z30-item-process-status-code>);
#    some do not.
# 2) The items in the <status> field are inconsistently spelled.
#
# In general, we want to use the processing status codes where available,
# because they have the cleanest data. So we have a mapping of status codes to
# our preferred display strings. However, when there isn't a status code, we
# also need a function for inferring it from the <status> field.
#
# Occasionally, we actually *do* want to use the <status> as provided by Aleph.
# (For instance, when the status is Claimed, the <status> is "Expected on
# $date"; as $date varies by item we can only get it by passing along the
# Aleph data.) In these cases, STATUS_MAP has nil for the code's value.
module ProcessingLabeler
  STATUS_MAP = {
    "AP" => "Pending Approval",
    "BO" => "Back Ordered",
    "CA" => "Cancelled Order",
    "CL" => nil,
    "CR" => "Long Overdue",
    "CS" => "Collections Support Unit",
    "CT" => "In Cataloging",
    "DW" => "Damaged/Withdrawn",
    "EX" => "On Exhibit",
    "IC" => "Improper Charge",
    "IL" => "BLC/BD ILB Item",  # Not available in bento.
    "IP" => "Ask for Assistance",
    "LO" => "Declared Long Overdue",
    "MM" => "Missing",
    "MR" => nil,
    "N/A" => "In Library",
    "NA" => "Expected/Not Yet Arrived",
    "NB" => "New Books Display",
    "NR" => "Never Received",
    "NT" => "Not Yet Published",
    "NV" => "Never Published",
    "OD" => "On Display",
    "OI" => "Order Initiated",
    "OO" => "On Order",
    "OP" => "Out of Print",
    "OS" => "On Search",
    "PR" => "Ask for Assistance",
    "RD" => "Received",
    "RO" => "Replacement Copy On Order",
    "SC" => "Offsite Reformatting/Scanning",
    "SF" => "Review for Reorder",
    "TS" => "Ask for Assistance",
    "ZA" => "Missing",
    "ZB" => "Missing",
    "ZC" => "Missing",
    "ZD" => "Missing",
    "ZE" => "Missing",
    "ZF" => "Missing",
    "ZG" => "Missing",
    "ZH" => "Missing",
    "ZI" => "Missing",
    "ZJ" => "Missing",
    "ZK" => "Missing",
    "ZL" => "Missing",
    "ZM" => "Missing",
    "ZN" => "Missing",
    "ZO" => "Missing"
  }

  def checked_out?(status)
    if %r(^due \d{2}/\d{2}/\d{4} \d{2}:\d{2} [a|p]m$).match(status.downcase)
      true
    else
      false
    end
  end

  # For statuses of the form "In Transit/Sublibrary; Due 03/26/2018 06:00 PM; Requested"
  # we want to strip out the due date part.
  def in_transit?(status)
    status.include?('In Transit/Sublibrary') && status.include?('Requested')
  end

  # In the interface, after "Available" or "Not Available", we often display
  # a string with additional information, in order to help users understand
  # the next action they should take or the amount of delay they should
  # expect. This string is based on the item status in Aleph, but we edit it
  # for readability.
  def processing_label(status, z30_item_process, reserve)
    return 'On reserve (see desk)' if reserve
    return 'Checked out' if checked_out?(status)
    return 'In Transit/Sublibrary; Requested' if in_transit?(status)

    mapped_status = STATUS_MAP[z30_item_process.upcase]
    return mapped_status if mapped_status.present?

    status
  end
end
