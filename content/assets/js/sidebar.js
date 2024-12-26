function toggleNav() {
    const nav = document.querySelector('.sidebar');
    const h2 = document.querySelector('div#sidebar h2');
    if (event.target.tagName != 'A') {
        if (nav.style.display === 'block') {
            h2.style.setProperty('--sidebar-arrow', '"⇓ "');
            nav.style.display = 'none';
        } else {
            h2.style.setProperty('--sidebar-arrow', '"⇑ "');
            nav.style.display = 'block';
        }
    }
}
