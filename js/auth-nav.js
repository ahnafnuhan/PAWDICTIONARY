import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = "https://huqlhlxukomrozoymvdh.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_dPY3CDRcFiCKG3HStHQbOA_w6mBHuBR";
const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);

const signInLink = document.querySelector('a[href="auth.html#signin"]');
const signUpLink = document.querySelector('a[href="auth.html#signup"]');

async function updateNavigation() {
    const { data: { session } } = await supabase.auth.getSession();

    if (!session) return;

    signInLink?.closest("li")?.remove();
    signUpLink?.closest("li")?.remove();

    const navLinks = document.querySelector(".nav-links");
    if (!navLinks) return;

    const existingUserLink = navLinks.querySelector(".nav-user");
    if (existingUserLink) return;

    const userMetadata = session.user.user_metadata || {};
    const name = userMetadata.name || userMetadata.full_name || "User";
    const avatarUrl = userMetadata.avatar_url
        || localStorage.getItem(`pawdictionary-avatar-${session.user.id}`);

    const item = document.createElement("li");
    item.className = "nav-user";
    item.innerHTML = avatarUrl
        ? `<a href="account.html" class="user-logo" aria-label="Open account for ${name}" title="${name}">
                <img src="${avatarUrl}" alt="">
           </a>`
        : `<a href="account.html" class="user-logo" aria-label="Open account for ${name}" title="${name}">
                <svg aria-hidden="true" viewBox="0 0 24 24">
                    <circle cx="12" cy="8" r="4"></circle>
                    <path d="M4 21a8 8 0 0 1 16 0"></path>
                </svg>
           </a>`;
    navLinks.appendChild(item);
}

updateNavigation();
