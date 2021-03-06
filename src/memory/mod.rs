
use self::paging::PhysicalAddress;

pub mod paging;
pub mod area_frame_allocator;
pub use self::area_frame_allocator::*;
pub use self::paging::test_paging;

pub const PAGE_SIZE: usize = 4096;

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Frame {
    number: usize,
}

impl Frame {
    // Private clone. Frame represent ownership so other libraries
    // should not be able to make new `Frame` values.
    fn clone(&self) -> Frame {
        Frame { number: self.number }
    }
    
    fn containing_address(address: usize) -> Frame {
        Frame { number: address / PAGE_SIZE }
    }

    pub fn start_address(&self) -> PhysicalAddress {
        self.number * PAGE_SIZE
    }
}

pub trait FrameAllocator {
    fn allocate_frame(&mut self) -> Option<Frame>;
    fn deallocate_frame(&mut self, frame: Frame);
}
