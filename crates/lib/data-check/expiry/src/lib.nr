use dep::utils::{IDData, get_array_slice, PASSPORT_MRZ_EXPIRY_DATE_INDEX, ID_CARD_MRZ_EXPIRY_DATE_INDEX, is_id_card};
use dep::date::Date;

pub fn check_expiry(id_data: IDData, current_date_bytes: [u8; 8]) {
    let bytes_mrz = id_data.mrz.as_bytes();

    // We base the threshold year for the expiry date on the current date plus 20 years
    // As most documents will have a 10 year validity (and some maybe 15 years?)
    // So with 20 years we should be safe
    let threshold_year = Date::from_bytes_long_year(current_date_bytes).add_years(20);
    let threshold_year_bytes = threshold_year.to_bytes();

    let current_date = Date::from_bytes_long_year(current_date_bytes);

    let mut expiry_date_bytes = [0 as u8; 6];

    if is_id_card(id_data) {
        expiry_date_bytes = get_array_slice(bytes_mrz, ID_CARD_MRZ_EXPIRY_DATE_INDEX, ID_CARD_MRZ_EXPIRY_DATE_INDEX + 6);
    } else {
        expiry_date_bytes = get_array_slice(bytes_mrz, PASSPORT_MRZ_EXPIRY_DATE_INDEX, PASSPORT_MRZ_EXPIRY_DATE_INDEX + 6);
    }

    let expiry_date = Date::from_bytes_short_year(
        expiry_date_bytes,
        [threshold_year_bytes[2], threshold_year_bytes[3]]
    );

    assert(current_date.lt(expiry_date));
}